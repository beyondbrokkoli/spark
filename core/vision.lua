-- core/vision.lua

require("core.palette")

VISION = {}

local LAST_COLOR = nil

function SAFE_SET_COLOR(colorTable)
    if LAST_COLOR ~= colorTable then
        love.graphics.setColor(colorTable)
        LAST_COLOR = colorTable
    end
end

function VISION.DrawHover(mx, my, cellSize)
    local idx = INPUT.GetMouseGrid(cellSize)
    if not idx then return end

    -- 1. Check the state of the node under the mouse
    local isSolid = NODE.Has(GRID_BUF[idx], NODE.FLAGS.SOLID)

    -- 2. Determine the "Twist" color
    local color = PALETTE.HOVER_EMPTY
    if isSolid then
        color = PALETTE.HOVER_ACTIVE
    end

    -- 3. Snap to grid for the visual overlay
    mx = mx - ((mx + CAMERA.x) % cellSize)
    my = my - ((my + CAMERA.y) % cellSize)

    SAFE_SET_COLOR(color)
    love.graphics.rectangle("fill", mx, my, cellSize, cellSize)
    SAFE_SET_COLOR(PALETTE.DEFAULT)
end

-- Update Draw to use the Blue color for SOLID nodes
function VISION.Draw(viewW, viewH, cellSize)
    local startX, startY, offX, offY = CAMERA.GetViewport(viewW, viewH, cellSize)

    -- We use the Blue from the old version
    SAFE_SET_COLOR(PALETTE.ACTIVE)

    for y = 0, viewH do
        for x = 0, viewW do
            local gx, gy = startX + x, startY + y
            if gx > 0 and gx <= GRID_SIZE and gy > 0 and gy <= GRID_SIZE then
                local idx = (gy - 1) * GRID_SIZE + gx
                if NODE.Has(GRID_BUF[idx], NODE.FLAGS.SOLID) then
                    love.graphics.rectangle("fill",
                        x * cellSize - offX,
                        y * cellSize - offY,
                        cellSize, cellSize)
                end
            end
        end
    end
end

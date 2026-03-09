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

function VISION.Draw(viewW, viewH, cellSize)
    local startX, startY, offX, offY = CAMERA.GetViewport(viewW, viewH, cellSize)

    SAFE_SET_COLOR(PALETTE.SOLID)

    -- Iterate through the visible window (+1 for partial squares at edges)
    for y = 0, viewH do
        for x = 0, viewW do
            local gx, gy = startX + x, startY + y

            -- Bounds check before buffer access
            if gx > 0 and gx <= GRID_SIZE and gy > 0 and gy <= GRID_SIZE then
                local idx = (gy - 1) * GRID_SIZE + gx
                if NODE.Has(GRID_BUF[idx], NODE.FLAGS.SOLID) then
                    -- Subtract the sub-pixel offset for smooth scrolling
                    love.graphics.rectangle("fill",
                        x * cellSize - offX,
                        y * cellSize - offY,
                        cellSize, cellSize)
                end
            end
        end
    end
end

function VISION.DrawHover(mx, my, cellSize)
    -- Reuse mx/my to store the snapped screen coordinates
    -- This removes the remainder (misalignment) from the current position
    mx = mx - ((mx + CAMERA.x) % cellSize)
    my = my - ((my + CAMERA.y) % cellSize)

    SAFE_SET_COLOR(PALETTE.HOVER)
    love.graphics.rectangle("fill", mx, my, cellSize, cellSize)
end

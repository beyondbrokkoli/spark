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

    local val = GRID_BUF[idx]
    local isSolid = NODE.Has(val, NODE.FLAGS.SOLID)
    local hasData = NODE.Has(val, NODE.FLAGS.DATA)

    -- 1. TEXT OVERLAY: Show JSON data if present
    if hasData then
        local data = PORTAL.Get(idx)
        love.graphics.setColor(1, 1, 1, 1) -- Ensure text is white
        love.graphics.print("DATA: " .. tostring(data.key) .. " -> " .. tostring(data.value), mx + 20, my - 20)
    end

    -- 2. COLOR SELECTION: The "Twist"
    local color = isSolid and PALETTE.HOVER_ACTIVE or PALETTE.HOVER_EMPTY

    -- 3. COORDINATE SNAPPING: Align highlight to the world grid
    local snapX = mx - ((mx + CAMERA.x) % cellSize)
    local snapY = my - ((my + CAMERA.y) % cellSize)

    -- 4. RENDER
    SAFE_SET_COLOR(color)
    love.graphics.rectangle("fill", snapX, snapY, cellSize, cellSize)
    SAFE_SET_COLOR(PALETTE.DEFAULT)
end

-- Update Draw to use the Blue color for SOLID nodes
-- old Draw retained for reference because we are adding SICK draw call optimizations
function VISION.old_Draw(viewW, viewH, cellSize)
    local startX, startY, offX, offY = CAMERA.GetViewport(viewW, viewH, cellSize)

    -- We use the Blue from the old version
    SAFE_SET_COLOR(PALETTE.ACTIVE)

    for y = 0, viewH do
        for x = 0, viewW do
            local gx, gy = startX + x, startY + y
            if gx > 0 and gx <= GRID_SIZE and gy > 0 and gy <= GRID_SIZE then
                local idx = (gy - 1) * GRID_SIZE + gx
                local val = GRID_BUF[idx]

                -- 1. Layer 1: Solid (Blue)
                if NODE.Has(val, NODE.FLAGS.SOLID) then
                    SAFE_SET_COLOR(PALETTE.ACTIVE)
                    love.graphics.rectangle("fill", x * cellSize - offX, y * cellSize - offY, cellSize, cellSize)
                end

                -- 2. Layer 2: Data (Green) - Completely separate from Solid!
                if NODE.Has(val, NODE.FLAGS.DATA) then
                    love.graphics.setColor(0, 1, 0, 0.4)
                    love.graphics.rectangle("line", x * cellSize - offX, y * cellSize - offY, cellSize, cellSize)
                end
            end
        end
    end
end

-- In core/vision.lua
function VISION.Draw(viewW, viewH, cellSize)
    local startX, startY, offX, offY = CAMERA.GetViewport(viewW, viewH, cellSize)

    for y = 0, viewH do
        for x = 0, viewW do
            local gx, gy = startX + x, startY + y
            if gx > 0 and gx <= GRID_SIZE and gy > 0 and gy <= GRID_SIZE then
                local idx = (gy - 1) * GRID_SIZE + gx
                local val = GRID_BUF[idx]

                -- LAYER 1: SOLID
                if NODE.Has(val, NODE.FLAGS.SOLID) then
                    SAFE_SET_COLOR(PALETTE.ACTIVE)
                    love.graphics.rectangle("fill", x * cellSize - offX, y * cellSize - offY, cellSize, cellSize)
                end

                -- LAYER 2: DATA
                if NODE.Has(val, NODE.FLAGS.DATA) then
                    love.graphics.setColor(0, 1, 0, 0.4)
                    love.graphics.rectangle("line", x * cellSize - offX, y * cellSize - offY, cellSize, cellSize)
                end

                -- CLEANUP: If we just processed a dirty node, clean it
                if NODE.Has(val, NODE.FLAGS.DIRTY) then
                    GRID_BUF[idx] = NODE.Clear(GRID_BUF[idx], NODE.FLAGS.DIRTY)
                end
            end
        end
    end
end

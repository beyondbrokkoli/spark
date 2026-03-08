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

function VISION.Draw(camX, camY, viewW, viewH, squareSize)
    SAFE_SET_COLOR(PALETTE.SOLID)
    -- i didnt change the lower part is it still correct?
    for y = camY, camY + viewH do
        for x = camX, camX + viewW do
            local idx = (y - 1) * GRID_SIZE + x
            if NODE.Has(GRID_BUF[idx], NODE.FLAGS.SOLID) then
                love.graphics.rectangle("fill", (x-1)*squareSize, (y-1)*squareSize, squareSize, squareSize)
            end
        end
    end
end
-- Add this
function VISION.DrawHover(mouseX, mouseY, cellSize)
    local idx = INPUT.ToIdx(mouseX, mouseY, cellSize)
    if idx then
        -- Calculate screen coords (Floor ensures clean, crisp lines)
        local gx = math.floor(mouseX / cellSize)
        local gy = math.floor(mouseY / cellSize)

        -- Highlighting: Draw a slightly transparent rectangle
        SAFE_SET_COLOR(PALETTE.HOVER) -- Highlight Overlay
        love.graphics.rectangle("fill", gx * cellSize, gy * cellSize, cellSize, cellSize)
    end
end

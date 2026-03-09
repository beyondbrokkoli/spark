-- core/debug.lua

function VISION.DrawDebug(cellSize)
    local mx, my = love.mouse.getPosition()
    local idx = INPUT.GetMouseGrid(cellSize)

    if idx then
        local val = GRID_BUF[idx]
        local debugText = string.format("Idx: %d\nBits: %s\nVal: %d",
            idx, DecToBin(val), val) -- DecToBin is a simple bit-string helper

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(debugText, mx + 15, my + 15)
    end
end

-- Utility
function DecToBin(n)
    local t = {}
    for i = 7, 0, -1 do -- Showing 8 bits for clarity
        t[#t+1] = math.floor(n / 2^i) % 2
    end
    return table.concat(t)
end

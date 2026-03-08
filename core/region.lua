-- core/region.lua
local bit = require("bit")
REGION = {}

-- Apply a bitmask operation to a rectangular area
-- GRID_BUF is accessed globally (defined in spark.lua)
function REGION.Apply(x1, y1, x2, y2, flag, operation)
    for y = y1, y2 do
        local rowOffset = (y - 1) * GRID_SIZE
        for x = x1, x2 do
            local idx = rowOffset + x
            if operation == "SET" then
                -- GRID_BUF[idx] = NODE.Set(GRID_BUF[idx], flag)
                GRID_BUF[idx] = bit.bor(GRID_BUF[idx], flag)
            elseif operation == "CLEAR" then
                -- GRID_BUF[idx] = NODE.Clear(GRID_BUF[idx], flag)
                GRID_BUF[idx] = bit.band(GRID_BUF[idx], bit.bnot(flag))
            end
        end
    end
end

-- core/node.lua
local bit = require("bit")

NODE = {
    FLAGS = {
        SOLID = 1,
        LIT   = 2,
        DIRTY = 4,
        DATA  = 8,
    }
}

function NODE.Has(nodeValue, flag)
    return bit.band(nodeValue, flag) ~= 0
end

function NODE.Set(nodeValue, flag)
    return bit.bor(nodeValue, flag)
end

function NODE.Clear(nodeValue, flag)
    return bit.band(nodeValue, bit.bnot(flag))
end

-- core/node.lua (Add this)
function NODE.Update(idx, flag, operation)
    local val = GRID_BUF[idx]
    if operation == "SET" then
        val = NODE.Set(val, flag)
    elseif operation == "CLEAR" then
        val = NODE.Clear(val, flag)
    end
    -- Mark as dirty so the renderer knows it changed
    val = NODE.Set(val, NODE.FLAGS.DIRTY)
    GRID_BUF[idx] = val
end

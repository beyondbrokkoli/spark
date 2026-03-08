-- core/node.lua
NODE = {
    FLAGS = {
        SOLID = bit.lshift(1, 0), -- 1
        LIT   = bit.lshift(1, 1), -- 2
        DIRTY = bit.lshift(1, 2), -- 4
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

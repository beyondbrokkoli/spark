-- core/spark.lua
local ffi = require("ffi")

SPARK = {}
GRID_BUF = nil -- Now a raw C pointer
GRID_SIZE = 0

function SPARK.Init(size)
    GRID_SIZE = size
    -- Allocates a flat block of uint8_t (1 byte per node).
    -- 10240x10240 now takes exactly 100MB of RAM.
    -- We need +1 so that index [size*size] is physically inside the memory block
    -- Allocate size^2 + 1 bytes.
    -- The +1 is a "ghost byte" to safely support 1-based indexing.
    -- NOTE: FFI arrays are 0-indexed in C, but LuaJIT lets us
    -- access them 1-indexed to keep your current math intact.
    GRID_BUF = ffi.new("uint8_t[?]", (size * size) + 1)
end

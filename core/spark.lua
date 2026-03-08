-- core/spark.lua
local bit = require("bit")

SPARK = {}
GRID_BUF = {}
GRID_SIZE = 0

function SPARK.Init(size)
    GRID_SIZE = size
    for i = 1, size * size do
        GRID_BUF[i] = 0
    end
end

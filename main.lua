-- main.lua
require("core.spark")
require("core.node")
require("core.region")
require("core.vision")
require("core.input")
require("core.bench")

function love.load()
    -- Initializing via the Spark namespace
    SPARK.Init(1024)

    local x1, y1, x2, y2 = 10, 10, 20, 20

    -- Region operations remain clear and fast
    REGION.Apply(x1, y1, x2, y2, NODE.FLAGS.SOLID, "SET")

    -- Verification
    local testIdx = (15 - 1) * GRID_SIZE + 15
    if NODE.Has(GRID_BUF[testIdx], NODE.FLAGS.SOLID) then
        print("Success: Node at 15,15 is SOLID.")
    end

    -- Benchmark the heavy lifting
    BENCH.Run("Full Grid Fill", function()
        REGION.Apply(1, 1, 1024, 1024, NODE.FLAGS.LIT, "SET")
    end)
end

function love.mousepressed(x, y, button)
    local idx = INPUT.ToIdx(x, y, 40) -- 40 = cellSize
    if idx then
        -- Toggle the SOLID flag surgically
        local current = GRID_BUF[idx]
        if NODE.Has(current, NODE.FLAGS.SOLID) then
            GRID_BUF[idx] = NODE.Clear(current, NODE.FLAGS.SOLID)
        else
            GRID_BUF[idx] = NODE.Set(current, NODE.FLAGS.SOLID)
        end
    end
end

function love.draw()
    local cellSize = 40

    -- 1. Draw the static grid state
    VISION.Draw(1, 1, 20, 15, cellSize)

    -- 2. Draw the transient hover overlay
    local mx, my = love.mouse.getPosition()
    VISION.DrawHover(mx, my, cellSize)
end

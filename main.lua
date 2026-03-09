-- main.lua
require("core.spark")
require("core.node")
require("core.region")
require("core.vision")
require("core.input")
require("core.camera")
require("core.bench")
require("core.debug")

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
    -- Use the new world-aware helper for clicks
    local idx = INPUT.GetMouseGrid(40)
    if idx then
        GRID_BUF[idx] = NODE.Set(GRID_BUF[idx], NODE.FLAGS.SOLID)
    end
end

function love.draw()
    local cellSize = 40
    local w, h = love.graphics.getDimensions()

    -- Determine how many cells fit on screen
    local viewW = math.ceil(w / cellSize)
    local viewH = math.ceil(h / cellSize)

    VISION.Draw(viewW, viewH, cellSize)

    local mx, my = love.mouse.getPosition()
    VISION.DrawHover(mx, my, cellSize)

    -- See the bit tricks in action
    VISION.DrawDebug(cellSize)
end

function love.update(dt)
    -- Smooth Camera Movement
    if love.keyboard.isDown("d") then CAMERA.x = CAMERA.x + CAMERA.speed * dt end
    if love.keyboard.isDown("a") then CAMERA.x = CAMERA.x - CAMERA.speed * dt end
    if love.keyboard.isDown("s") then CAMERA.y = CAMERA.y + CAMERA.speed * dt end
    if love.keyboard.isDown("w") then CAMERA.y = CAMERA.y - CAMERA.speed * dt end
end

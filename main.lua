-- main.lua
require("core.settings") -- Load this first!
require("core.spark")
require("core.node")
require("core.region")
require("core.vision")
require("core.input")
require("core.camera")
require("core.bench")
require("core.debug")

function love.load()
    SPARK.Init(SETTINGS.GRID_BUFFER_SIZE)

    -- Use SETTINGS instead of hardcoded numbers to verify
    local mid = math.floor(SETTINGS.GRID_BUFFER_SIZE / 2)
    REGION.Apply(mid, mid, mid + 5, mid + 5, NODE.FLAGS.SOLID, "SET")

    -- Benchmark the WHOLE grid dynamically
    BENCH.Run("Full Grid Fill", function()
        REGION.Apply(1, 1, SETTINGS.GRID_BUFFER_SIZE, SETTINGS.GRID_BUFFER_SIZE, NODE.FLAGS.LIT, "SET")
    end)
end

function love.mousepressed(x, y, button)
    -- Use the new world-aware helper for clicks
    local idx = INPUT.GetMouseGrid(SETTINGS.CELL_SIZE)
    if idx then
        GRID_BUF[idx] = NODE.Set(GRID_BUF[idx], NODE.FLAGS.SOLID)
    end
end

function love.draw()
    local cellSize = SETTINGS.CELL_SIZE
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
    local cfg = SETTINGS -- Local alias for speed and brevity
    local screenW, screenH = love.graphics.getDimensions()
    local maxPixel = GRID_SIZE * cfg.CELL_SIZE

    -- 1. CAMERA MOVEMENT (Using dynamic keys and speed)
    if love.keyboard.isDown(cfg.KEYS.RIGHT) then CAMERA.x = CAMERA.x + cfg.CAMERA_SPEED * dt end
    if love.keyboard.isDown(cfg.KEYS.LEFT)  then CAMERA.x = CAMERA.x - cfg.CAMERA_SPEED * dt end
    if love.keyboard.isDown(cfg.KEYS.DOWN)  then CAMERA.y = CAMERA.y + cfg.CAMERA_SPEED * dt end
    if love.keyboard.isDown(cfg.KEYS.UP)    then CAMERA.y = CAMERA.y - cfg.CAMERA_SPEED * dt end

    -- 2. CAMERA BOUNDS
    CAMERA.x = math.max(0, math.min(CAMERA.x, maxPixel - screenW))
    CAMERA.y = math.max(0, math.min(CAMERA.y, maxPixel - screenH))

    -- 3. INTERACTION
    local idx = INPUT.GetMouseGrid(cfg.CELL_SIZE)
    if idx then
        if love.mouse.isDown(1) then
            if love.keyboard.isDown(cfg.KEYS.ERASE) then
                GRID_BUF[idx] = NODE.Clear(GRID_BUF[idx], NODE.FLAGS.SOLID)
            else
                GRID_BUF[idx] = NODE.Set(GRID_BUF[idx], NODE.FLAGS.SOLID)
            end
        end
    end
end

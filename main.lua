-- main.lua
require("core.settings") -- Load this first!
require("core.spark")
require("core.node")
require("core.region")
require("core.vision")
require("core.input")
require("core.camera")
require("core.portal")
require("core.bench")
require("core.debug")

-- awaking the ogre
function love.load()
    SPARK.Init(SETTINGS.GRID_BUFFER_SIZE)

    -- 1. COORDINATE SPACE: Create a solid 5x5 square in the center
    local midCoord = math.floor(SETTINGS.GRID_BUFFER_SIZE / 2)
    REGION.Apply(midCoord, midCoord, midCoord + 5, midCoord + 5, NODE.FLAGS.SOLID, "SET")

    -- 2. BITWISE LAYER: Light up the whole world (doesn't delete the square!)
    BENCH.Run("Full Grid Fill", function()
        REGION.Apply(1, 1, SETTINGS.GRID_BUFFER_SIZE, SETTINGS.GRID_BUFFER_SIZE, NODE.FLAGS.LIT, "SET")
    end)

    -- 3. INDEX SPACE: Inject JSON at the specific linear center
    -- adjust to ffi by subtracting one for the crew
    local midIdx = (midCoord - 1) * SETTINGS.GRID_BUFFER_SIZE + midCoord
    local myData = { status = "Giga-Ogre Online", kernel = "LÖVE 11.5", arch = "FFI" }
    PORTAL.WalkAndInject(myData, midIdx)
end

function love.mousepressed(x, y, button)
    -- Use the new world-aware helper for clicks
    local idx = INPUT.GetMouseGrid(SETTINGS.CELL_SIZE)
    if idx then
        local op = love.keyboard.isDown(SETTINGS.KEYS.ERASE) and "CLEAR" or "SET"
        NODE.Update(idx, NODE.FLAGS.SOLID, op)
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

function love.keypressed(key)
    -- Add this to love.keypressed
    if key == "t" then
        local midCoord = math.floor(SETTINGS.GRID_BUFFER_SIZE / 2)
        -- Align camera (pixels) to the center grid coordinate
        CAMERA.x = (midCoord - 1) * SETTINGS.CELL_SIZE
        CAMERA.y = (midCoord - 1) * SETTINGS.CELL_SIZE
    end
    if key == "escape" then love.event.quit() end
end

-- main.lua
require("core.settings")
require("core.node")
require("core.region")
require("core.vision")
require("core.input")
require("core.camera")
require("core.portal")
require("core.bench")

function love.load()
    NODE.Init(SETTINGS.GRID_BUFFER_SIZE)
    local midCoord = math.floor(SETTINGS.GRID_BUFFER_SIZE / 2)
    REGION.Apply(midCoord, midCoord, midCoord + 5, midCoord + 5, NODE.FLAGS.SOLID, "SET")
    BENCH.Run("Full Grid Fill", function()
        REGION.Apply(1, 1, SETTINGS.GRID_BUFFER_SIZE, SETTINGS.GRID_BUFFER_SIZE, NODE.FLAGS.LIT, "SET")
    end)
    local midIdx = (midCoord - 1) * SETTINGS.GRID_BUFFER_SIZE + midCoord
    local myData = { status = "Giga-Ogre Online", kernel = "LÖVE 11.5", arch = "FFI" }
    PORTAL.WalkAndInject(myData, midIdx)
end

function love.mousepressed(x, y, button)
    local idx = INPUT.GetMouseGrid(SETTINGS.CELL_SIZE)
    if idx then
        local op = love.keyboard.isDown(SETTINGS.KEYS.ERASE) and "CLEAR" or "SET"
        NODE.Update(idx, NODE.FLAGS.SOLID, op)
    end
end

function love.draw()
    local cellSize = SETTINGS.CELL_SIZE
    local w, h = love.graphics.getDimensions()
    local viewW = math.ceil(w / cellSize)
    local viewH = math.ceil(h / cellSize)

    VISION.Draw(viewW, viewH, cellSize)

    local mx, my = love.mouse.getPosition()
    VISION.DrawHover(mx, my, cellSize)
    VISION.DrawDebug(cellSize)
end

function love.update(dt)
    local cfg = SETTINGS
    local screenW, screenH = love.graphics.getDimensions()
    local maxPixel = NODE.SIZE * cfg.CELL_SIZE
    if love.keyboard.isDown(cfg.KEYS.RIGHT) then CAMERA.x = CAMERA.x + cfg.CAMERA_SPEED * dt end
    if love.keyboard.isDown(cfg.KEYS.LEFT)  then CAMERA.x = CAMERA.x - cfg.CAMERA_SPEED * dt end
    if love.keyboard.isDown(cfg.KEYS.DOWN)  then CAMERA.y = CAMERA.y + cfg.CAMERA_SPEED * dt end
    if love.keyboard.isDown(cfg.KEYS.UP)    then CAMERA.y = CAMERA.y - cfg.CAMERA_SPEED * dt end
    CAMERA.x = math.max(0, math.min(CAMERA.x, maxPixel - screenW))
    CAMERA.y = math.max(0, math.min(CAMERA.y, maxPixel - screenH))
    local idx = INPUT.GetMouseGrid(cfg.CELL_SIZE)
    if idx then
        if love.mouse.isDown(1) then
            local op = love.keyboard.isDown(cfg.KEYS.ERASE) and "CLEAR" or "SET"
            -- CALL NODE.Update to trigger the Dirty Flag!
            NODE.Update(idx, NODE.FLAGS.SOLID, op)
        end
    end
end

function love.keypressed(key)
    if key == "c" then
        BENCH.Run("Chaos Fill", function()
            local cellSize = SETTINGS.CELL_SIZE
            local gx = math.floor(CAMERA.x / cellSize) + 1
            local gy = math.floor(CAMERA.y / cellSize) + 1
            REGION.RandomFill(gx, gy, gx + 500, gy + 500, 0.5)
        end)
    end
    if key == "t" then
        local midCoord = math.floor(SETTINGS.GRID_BUFFER_SIZE / 2)
        CAMERA.x = (midCoord - 1) * SETTINGS.CELL_SIZE
        CAMERA.y = (midCoord - 1) * SETTINGS.CELL_SIZE
    end
    if key == "escape" then love.event.quit() end
end
function love.wheelmoved(x, y)
    -- Zoom in/out with the mouse wheel
    local zoomSpeed = 0.1
    local oldZoom = SETTINGS.CELL_SIZE

    if y > 0 then
        SETTINGS.CELL_SIZE = math.min(20, SETTINGS.CELL_SIZE + zoomSpeed)
    elseif y < 0 then
        SETTINGS.CELL_SIZE = math.max(0.1, SETTINGS.CELL_SIZE - zoomSpeed)
    end

    -- Optional: Adjust camera so we zoom toward the mouse position
    -- (This requires a bit more math, but even a basic zoom feels great now)
end

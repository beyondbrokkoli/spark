-- core/vision.lua
require("core.palette")
local ffi = require("ffi")

VISION = {}

local LAST_COLOR = nil

function SAFE_SET_COLOR(colorTable)
    if LAST_COLOR ~= colorTable then
        love.graphics.setColor(colorTable)
        LAST_COLOR = colorTable
    end
end

local function rebuildChunk(cIdx)
    local chunk = CHUNKS[cIdx]
    local chunksAcross = math.ceil(NODE.SIZE / CHUNK_SIZE)
    local cy = math.floor(cIdx / chunksAcross)
    local cx = cIdx % chunksAcross
    local startGX, startGY = cx * CHUNK_SIZE + 1, cy * CHUNK_SIZE + 1

    -- Get a pointer to the raw pixel data (RGBA8)
    local pointer = ffi.cast("uint32_t*", chunk.data:getPointer())

    -- Pre-calculate colors as 32-bit integers (0xAABBGGRR)
    local white = 0xFFFFFFFF
    local transparent = 0x00000000

    for y = 0, CHUNK_SIZE - 1 do
        local gy = startGY + y
        local rowBase = (gy - 1) * NODE.SIZE
        local destRowOffset = y * CHUNK_SIZE -- Pointer is 1D

        for x = 0, CHUNK_SIZE - 1 do
            local gx = startGX + x
            local val = NODE.BUFFER[rowBase + gx]

            -- Direct pointer assignment (Super Fast)
            if bit.band(val, NODE.FLAGS.SOLID) ~= 0 then
                pointer[destRowOffset + x] = white
            else
                pointer[destRowOffset + x] = transparent
            end
        end
    end

    if not chunk.img then
        chunk.img = love.graphics.newImage(chunk.data)
        chunk.img:setFilter("nearest", "nearest")
    else
        chunk.img:replacePixels(chunk.data)
    end
    chunk.isDirty = false
end

function VISION.Draw(viewW, viewH, cellSize)
    local chunksAcross = math.ceil(NODE.SIZE / CHUNK_SIZE)

    -- Calculate visible chunk range
    local startCX = math.floor(CAMERA.x / (CHUNK_SIZE * cellSize))
    local startCY = math.floor(CAMERA.y / (CHUNK_SIZE * cellSize))
    local endCX = math.floor((CAMERA.x + (viewW * cellSize)) / (CHUNK_SIZE * cellSize))
    local endCY = math.floor((CAMERA.y + (viewH * cellSize)) / (CHUNK_SIZE * cellSize))

    love.graphics.setColor(PALETTE.ACTIVE)
    for cy = startCY, endCY do
        for cx = startCX, endCX do
            local cIdx = (cy * chunksAcross) + cx
            local chunk = CHUNKS[cIdx]

            if chunk then
                -- 1. Changed check from .batch to .img
                if chunk.isDirty or not chunk.img then
                    rebuildChunk(cIdx)
                end

                local drawX = (cx * CHUNK_SIZE * cellSize) - CAMERA.x
                local drawY = (cy * CHUNK_SIZE * cellSize) - CAMERA.y

                -- 2. Draw the image and scale it by cellSize
                -- love.graphics.draw(drawable, x, y, r, sx, sy)
                love.graphics.draw(chunk.img, drawX, drawY, 0, cellSize, cellSize)
            end
        end
    end
end

function VISION.DrawHover(mx, my, cellSize)
    local idx = INPUT.GetMouseGrid(cellSize)
    if not idx then return end

    -- FFI Optimization: Direct access
    local val = NODE.BUFFER[idx]
    local isSolid = bit.band(val, NODE.FLAGS.SOLID) ~= 0
    local hasData = bit.band(val, NODE.FLAGS.DATA) ~= 0

    if hasData then
        local data = PORTAL.Get(idx)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print("DATA: " .. tostring(data.key), mx + 20, my - 20)
    end

    local color = isSolid and PALETTE.HOVER_ACTIVE or PALETTE.HOVER_EMPTY

    -- Fast Snap Math
    local snapX = mx - ((mx + CAMERA.x) % cellSize)
    local snapY = my - ((my + CAMERA.y) % cellSize)

    SAFE_SET_COLOR(color)
    love.graphics.rectangle("fill", snapX, snapY, cellSize, cellSize)
    SAFE_SET_COLOR(PALETTE.DEFAULT)
end

function VISION.DrawDebug(cellSize)
    local mx, my = love.mouse.getPosition()
    local idx = INPUT.GetMouseGrid(cellSize)

    -- Move cursor debug to top-left for better visibility during zoom
    love.graphics.setColor(0, 1, 0, 1) -- Bright Green for Engine Stats
    local stats = string.format(
        "Cam: %.0f, %.0f\nZoom: %.2f\nChunks: %d\nMemory: %.2f MB",
        CAMERA.x, CAMERA.y, cellSize, #CHUNKS, collectgarbage("count") / 1024
    )
    love.graphics.print(stats, 10, 10)

    -- Show our new persistent Benchmarks
    local yOffset = 80
    for label, _ in pairs(BENCH.registry) do
        love.graphics.print(label .. " " .. BENCH.GetStats(label), 10, yOffset)
        yOffset = yOffset + 15
    end

    -- Original mouse-over logic
    if idx then
        local val = NODE.BUFFER[idx]
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(string.format("Idx: %d\nVal: %d", idx, val), mx + 15, my + 15)
    end
end

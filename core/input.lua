-- core/input.lua
INPUT = {}

-- Maps pixel (x, y) to grid index (1-based)
function INPUT.ToIdx(pixelX, pixelY, cellSize)
    local gridX = math.floor(pixelX / cellSize) + 1
    local gridY = math.floor(pixelY / cellSize) + 1

    -- OOB Check (Bounds Guard)
    if gridX < 1 or gridX > GRID_SIZE or gridY < 1 or gridY > GRID_SIZE then
        return nil
    end

    return (gridY - 1) * GRID_SIZE + gridX
end

-- camera and mouse logic
function INPUT.GetMouseGrid(cellSize)
    local mx, my = love.mouse.getPosition()
    -- Translate screen-space mouse to world-space
    local worldX = mx + CAMERA.x
    local worldY = my + CAMERA.y
    return INPUT.ToIdx(worldX, worldY, cellSize)
end

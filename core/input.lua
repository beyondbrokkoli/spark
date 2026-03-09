-- core/input.lua
INPUT = {}

-- Maps pixel (x, y) to grid index (1-based)
function INPUT.ToIdx(pixelX, pixelY, cellSize)
    local gridX = math.floor(pixelX / cellSize) + 1
    local gridY = math.floor(pixelY / cellSize) + 1

    -- OOB Check (Bounds Guard)
    -- THE FORTRESS: Strict bounds checking
    if gridX < 1 or gridX > GRID_SIZE or gridY < 1 or gridY > GRID_SIZE then
        return nil
    end


    local idx = (gridY - 1) * GRID_SIZE + gridX

    -- THE MATH DRIFT GUARD: 
    -- Ensures the index actually exists in the allocated C-buffer.
    if not idx or idx < 1 or idx > (GRID_SIZE * GRID_SIZE) then
        return nil
    end
    return idx
end

-- camera and mouse logic
function INPUT.GetMouseGrid(cellSize)
    local mx, my = love.mouse.getPosition()
    -- Translate screen-space mouse to world-space
    local worldX = mx + CAMERA.x
    local worldY = my + CAMERA.y
    return INPUT.ToIdx(worldX, worldY, cellSize)
end

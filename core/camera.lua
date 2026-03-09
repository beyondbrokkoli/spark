-- core/camera.lua

CAMERA = {
    x = 0, -- Pixel X
    y = 0, -- Pixel Y
}

function CAMERA.GetViewport(viewW, viewH, cellSize)
    -- Translates pixel position to the starting grid indices
    local startX = math.floor(CAMERA.x / cellSize) + 1
    local startY = math.floor(CAMERA.y / cellSize) + 1

    -- Returns indices and the sub-pixel "remainder" for smooth offset drawing
    local offsetX = CAMERA.x % cellSize
    local offsetY = CAMERA.y % cellSize

    return startX, startY, offsetX, offsetY
end

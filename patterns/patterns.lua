require "maze1"
require "maze2"
require "maze3"
require "mandelbrot"
require "jaggedislands"
require "barcode"
require "distort"
require "simple"
require "transforms"
require "convolve"

function Safe(pattern, r)
    local radius = r or 4
    return Union(pattern, Circle(radius))
end

-- Given a pattern that returns 'true' for land and 'false' for water,
-- create a pattern that returns a string, either "land" or a suitable tile name.
-- Creates grass borders around water as appropriate.
-- Configurable water color.
function TerrainPattern(pattern, watercolor)
    local is_land = pattern.get -- Returns 'true' for land, 'false' or 'nil' for water
    local k = 2 -- Border thickness, and minimum feature size
    local water, deepwater
    if watercolor == "green" then
        water = "water-green"
        deepwater = "deepwater-green"
    else
        watercolor = "blue"
        water = "water"
        deepwater = "deepwater"
    end

    local function create()
        return pattern.create()
    end

    local function reload(d)
        pattern.reload(d)
    end

    local function get(x, y)
        if is_land(x, y) then
            if is_land(x - k, y - k) and is_land(x - k, y + k) and is_land(x + k, y - k) and is_land(x + k, y + k) then
                return "land"
            else
                return "grass"
            end
        else
            if is_land(x - k, y - k) or is_land(x - k, y + k) or is_land(x + k, y - k) or is_land(x + k, y + k) then
                return water
            else
                return deepwater
            end
        end
    end

    return {
        create = create,
        reload = reload,
        get = get,
        lua = 'TerrainPattern(' .. pattern.lua .. ', "' .. watercolor .. '")'
    }
end

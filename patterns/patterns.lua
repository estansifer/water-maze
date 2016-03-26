require "maze1"
require "maze2"
require "maze3"

local function noop()
    return nil
end

function Cross(halfwidth)
    local n = halfwidth or 1
    local function get(x, y)
        return (x >= -n and x < n) or (y >= -n and y < n)
    end
    return {create = noop, reload = noop, get = get, lua = 'Cross(' .. n .. ')'}
end

function Comb()
    local function get(x, y)
        if x < -1 then
            return false
        elseif x < 2 then
            return true
        else
            return (y % 2) == 0
        end
    end
    return {create = noop, reload = noop, get = get, lua = 'Comb()'}
end

function Grid()
    local function get(x, y)
        return (((x + 1) % 4) < 2) or (((y + 1) % 4) < 2)
    end
    return {create = noop, reload = noop, get = get, lua = 'Grid()'}
end

function Islands(islandradius, pathlength, pathwidth)
    local r = islandradius or 32
    local k = pathlength or 48
    local w = pathwidth or 2
    local n = 2 * r + w + k
    local function get(x, y)
        x = x % n
        y = y % n
        if (x < w) or (y < w) then
            return true
        else
            x = (x + r) % n
            y = (y + r) % n
            return (x < 2 * r + w) and (y < 2 * r + w)
        end
    end
    local lua = 'Islands(' .. r .. ', ' .. k .. ', ' .. w .. ')'
    return {create = noop, reload = noop, get = get, lua = lua}
end

-- This pattern is based on an idea and code by Donovan Hawkins:
-- https://forums.factorio.com/viewtopic.php?f=94&t=21568&start=10#p138292
function Islandify(pattern, islandradius, pathlength, pathwidth)
    local pattern_get = pattern.get
    local r = islandradius or 32
    local k = pathlength or 48
    local w = pathwidth or 2
    local n = 2 * r + w + k

    local function create()
        return pattern.create()
    end

    local function reload(d)
        pattern.reload(d)
    end

    local function get(x, y)
        local px = math.floor((x + r) / n)
        local py = math.floor((y + r) / n)
        if not pattern_get(px, py) then
            return false
        end
        x = x % n
        y = y % n
        if (x < w and pattern_get(px, py + 1)) or (y < w and pattern_get(px + 1, py)) then
            return true
        else
            x = (x + r) % n
            y = (y + r) % n
            return (x < 2 * r + w) and (y < 2 * r + w)
        end
    end

    return {
        create = create,
        reload = reload,
        get = get,
        lua = 'Islandify(' .. pattern.lua .. ', ' .. r .. ', ' .. k .. ', ' .. w .. ')'
    }
end

function Zoom(pattern, f)
    local factor = n or 16
    local pattern_get = pattern.get

    local function create()
        return pattern.create()
    end

    local function reload(d)
        pattern.reload(d)
    end

    local function get(x, y)
        return pattern_get(math.floor(x / factor), math.floor(y / factor))
    end

    return {
        create = create,
        reload = reload,
        get = get,
        lua = 'Zoom(' .. pattern.lua .. ', ' .. factor .. ')'
    }
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

function Island(radius)
    local r = radius or 1
    local function get(x, y)
        return x >= -r and y >= -r and x < r and y < r
    end
    return {create = noop, reload = noop, get = get, lua = 'Island(' .. r .. ')'}
end

function Roundisland(radius)
    local r = radius or 32
    local function get(x, y)
        return (x * x) + (y * y) < r * r
    end
    return {create = noop, reload = noop, get = get, lua = 'Roundisland(' .. r .. ')'}
end

function Halfplane()
    local function get(x, y)
        return (x >= -1)
    end
    return {create = noop, reload = noop, get = get, lua = 'Halfplane()'}
end

function Quarterplane()
    local function get(x, y)
        return (x >= -1) and (y >= -1)
    end
    return {create = noop, reload = noop, get = get, lua = 'Quarterplane()'}
end

function Union(p1, p2)
    local p1get = p1.get
    local p2get = p2.get

    local function create()
        return {p1.create(), p2.create()}
    end

    local function reload(d)
        p1.reload(d[1])
        p2.reload(d[2])
    end

    local function get(x, y)
        return p1get(x, y) or p2get(x, y)
    end

    return {
        create = create,
        reload = reload,
        get = get,
        lua = 'Union(' .. p1.lua .. ', ' .. p2.lua .. ')'
    }
end

function Intersection(p1, p2)
    local p1get = p1.get
    local p2get = p2.get

    local function create()
        return {p1.create(), p2.create()}
    end

    local function reload(d)
        p1.reload(d[1])
        p2.reload(d[2])
    end

    local function get(x, y)
        return p1get(x, y) and p2get(x, y)
    end

    return {
        create = create,
        reload = reload,
        get = get,
        lua = 'Intersection(' .. p1.lua .. ', ' .. p2.lua .. ')'
    }
end

function Translate(pattern, dx, dy)
    local pget = pattern.get

    local function create()
        return pattern.create()
    end

    local function reload(d)
        pattern.reload(d)
    end

    local function get(x, y)
        return pget(x - dx, y - dy)
    end

    return {
        create = create,
        reload = reload,
        get = get,
        lua = 'Translate(' .. pattern.lua .. ', ' .. dx .. ', ' .. dy .. ')'
    }
end

-- function safety(pattern)
    -- return union(pattern, island(1))
-- end

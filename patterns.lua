maze1 = require "maze1"
maze2 = require "diffusion"
maze3 = require "percolation"

function cross(halfwidth)
    local n = halfwidth or 1
    local function get(x, y)
        return (x >= -n and x < n) or (y >= -n and y < n)
    end
    return {get = get, lua = 'cross(' .. n .. ')'}
end

function comb()
    local function get(x, y)
        if x < -1 then
            return false
        elseif x < 2 then
            return true
        else
            return (y % 2) == 0
        end
    end
    return {get = get, lua = 'comb()'}
end

function grid()
    local function get(x, y)
        return ((x % 2) == 0) or ((y % 2) == 0)
    end
    local get2 = safety({get = get, lua = 'nil'}).get
    return {get = get2, lua = 'grid()'}
end

function islands(islandradius, pathlength, pathwidth)
    local r = islandradius or 32
    local k = pathlength or 64
    local w = pathwidth or 2
    local n = 2 * r + w + k
    local function get(x, y)
        x = (x + 1) % n
        y = (y + 1) % n
        if (x < 2 * r + w) and (y < 2 * r + w) then
            return true
        else
            return ((x >= r) and (x < r + w)) or ((y >= r) and (y < r + w))
        end
    end
    return {get = get, lua = 'islands(' .. r .. ', ' .. k .. ', ' .. w .. ')'}
end

function chunkify(pattern, n)
    local chunk_size = n or 16
    local pattern_get = pattern.get
    local function get(x, y)
        return pattern_get(math.floor(x / chunk_size), math.floor(y / chunk_size))
    end
    return {get = get, lua = 'chunkify(' .. pattern.lua .. ', ' .. chunk_size .. ')'}
end

function add_land_boundary(pattern, watercolor)
    local is_land = pattern.get
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

    return {get = get, lua = 'add_land_boundary(' .. pattern.lua .. ', "' .. watercolor .. '")'}
end

function island(radius)
    local r = radius or 1
    local function get(x, y)
        return x >= -r and y >= -r and x < r and y < r
    end
    return {get = get, lua = 'island(' .. r .. ')'}
end

function roundisland(radius)
    local r = radius or 32
    local function get(x, y)
        return (x * x) + (y * y) < r * r
    end
    return {get = get, lua = 'roundisland(' .. r .. ')'}
end

function halfplane()
    local function get(x, y)
        return (x >= -1)
    end
    return {get = get, lua = 'halfplane()'}
end

function quarterplane()
    local function get(x, y)
        return (x >= -1) and (y >= -1)
    end
    return {get = get, lua = 'quarterplane()'}
end

function union(p1, p2)
    local p1get = p1.get
    local p2get = p2.get
    local function get(x, y)
        return p1get(x, y) or p2get(x, y)
    end
    return {get = get, lua = 'union(' .. p1.lua .. ', ' .. p2.lua .. ')'}
end

function intersection(p1, p2)
    local p1get = p1.get
    local p2get = p2.get
    local function get(x, y)
        return p1get(x, y) and p2get(x, y)
    end
    return {get = get, lua = 'intersection(' .. p1.lua .. ', ' .. p2.lua .. ')'}
end

function translate(p, dx, dy)
    local pget = p.get
    local function get(x, y)
        return p.get(x - dx, y - dy)
    end
    return {get = get, lua = 'translate(' .. p.lua .. ', ' .. dx .. ', ' .. dy .. ')'}
end

function safety(pattern)
    local get2 = union({get = pattern.get, lua = 'nil'}, island(1)).get
    return {get = get2, lua = 'safety(' .. pattern.lua .. ')'}
end

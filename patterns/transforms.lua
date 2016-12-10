require 'simple'

function Zoom(pattern, f)
    local factor = f or 16
    local pget = pattern.get

    local function create()
        return pattern.create()
    end

    local function reload(d)
        pattern.reload(d)
    end

    local function get(x, y)
        return pget(x / factor, y / factor)
    end

    return {
        create = create,
        reload = reload,
        get = get,
        lua = 'Zoom(' .. pattern.lua .. ', ' .. factor .. ')'
    }
end

function Invert(pattern)
    local pget = pattern.get

    local function create()
        return pattern.create()
    end

    local function reload(d)
        pattern.reload(d)
    end

    local function get(x, y)
        return not pget(x, y)
    end

    return {
        create = create,
        reload = reload,
        get = get,
        lua = 'Invert(' .. pattern.lua .. ')'
    }
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

-- Shifts the given pattern by dx to the right and dy up
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

-- Given an angle in degrees, rotates anticlockwise by that much
function Rotate(pattern, angle)
    local pget = pattern.get
    local c = math.cos(angle * math.pi / 180)
    local s = math.sin(angle * math.pi / 180)

    local function create()
        return pattern.create()
    end

    local function reload(d)
        pattern.reload(d)
    end

    local function get(x, y)
        return pget(c * x + s * y, -s * x + c * y)
    end

    return {
        create = create,
        reload = reload,
        get = get,
        lua = 'Rotate(' .. pattern.lua .. ', ' .. angle .. ')'
    }
end

function Affine(pattern, a, b, c, d, dx, dy)
    local pget = pattern.get
    dx = dx or 0
    dy = dy or 0

    local function create()
        return pattern.create()
    end

    local function reload(d)
        pattern.reload(d)
    end

    local function get(x, y)
        return pget(a * x + b * y + dx, c * x + d * y + dy)
    end

    return {
        create = create,
        reload = reload,
        get = get,
        lua = ('Affine(' .. pattern.lua .. ', ' .. a .. ', ' .. b .. ', ' .. c .. ', ' .. d ..
            ', ' .. dx .. ', ' .. dy .. ')')
    }
end

-- Tiles the plane with the contents of the given pattern from [0, xsize) x [0, ysize)
function Tile(pattern, xsize, ysize)
    local pget = pattern.get

    local function create()
        return pattern.create()
    end

    local function reload(d)
        pattern.reload(d)
    end

    local function get(x, y)
        return pget(x % xsize, y % ysize)
    end

    return {
        create = create,
        reload = reload,
        get = get,
        lua = 'Tile(' .. pattern.lua .. ', ' .. xsize .. ',' .. ysize .. ')'
    }
end

-- Similar to the z -> z^k function, repeats the given pattern k times by squeezing
-- k copies angularly around the origin.
-- If you can come up with a better name for this, let me know.
function AngularRepeat(pattern, k)
    local pget = pattern.get

    local function create()
        return pattern.create()
    end

    local function reload(d)
        pattern.reload(d)
    end

    local function get(x, y)
        if x == 0 and y == 0 then
            return pget(0, 0)
        else
            -- This could be done without trig functions but this just seems easier
            local alpha = k * math.atan2(y, x)
            local r = math.sqrt(x * x + y * y)
            local x_ = r * math.cos(alpha)
            local y_ = r * math.sin(alpha)
            return pget(x_, y_)
        end
    end

    return {
        create = create,
        reload = reload,
        get = get,
        lua = 'AngularRepeat(' .. pattern.lua .. ', ' .. k .. ')'
    }
end

-- Adds jitter to the boundaries of the given pattern; radius controls the size of the
-- jitter.
function Jitter(pattern, radius)
    local pget = pattern.get
    local r = radius or 10
    local data

    local function create()
        data = {}
        data.values = {}
        data.pattern = pattern.create()
        return data
    end

    local function reload(d)
        data = d
        pattern.reload(data.pattern)
    end

    local function compute(x, y)
        local dx = (math.random() + math.random() - 1) * (r / 2)
        local dy = (math.random() + math.random() - 1) * (r / 2)
        return pget(x + dx, y + dy)
    end

    local function geti(x, y)
        local key = x .. '#' .. y
        if data.values[key] == nil then
            data.values[key] = compute(x, y)
        end
        return data.values[key]
    end

    local function get(x, y)
        return geti(math.floor(x + 0.5), math.floor(y + 0.5))
    end

    return {
        create = create,
        reload = reload,
        get = get,
        lua = 'Jitter(' .. pattern.lua .. ', ' .. r .. ')'
    }
end

-- Poor performance, don't use
function Smooth(pattern, radius)
    local pget = pattern.get
    local r = radius or 3

    local dx = {}
    local dy = {}
    local total = 0
    for i = -r,r+1 do
        for j = -r,r+1 do
            if i * i + j * j <= r * r then
                table.insert(dx, i)
                table.insert(dy, j)
                total = total + 1
            end
        end
    end

    local data

    local function create()
        data = {}
        data.values = {}
        data.pattern = pattern.create()
        return data
    end

    local function reload(d)
        data = d
        pattern.reload(data.pattern)
    end

    local function compute(x, y)
        local count = 0
        for i = 1,total do
            if pget(x + dx[i], y + dy[i]) then
                count = count + 1
            end
        end
        return count * 2 > total
    end

    local function geti(x, y)
        local key = x .. '#' .. y
        if data.values[key] == nil then
            data.values[key] = compute(x, y)
        end
        return data.values[key]
    end

    local function get(x, y)
        return geti(math.floor(x + 0.5), math.floor(y + 0.5))
    end

    return {
        create = create,
        reload = reload,
        get = get,
        lua = 'Jitter(' .. pattern.lua .. ', ' .. r .. ')'
    }
end

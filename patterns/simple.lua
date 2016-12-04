local function noop()
    return nil
end

function AllLand()
    local function get(x, y)
        return true
    end
    return {create = noop, reload = noop, get = get, lua = 'AllLand()'}
end

function AllWater()
    local function get(x, y)
        return false
    end
    return {create = noop, reload = noop, get = get, lua = 'AllLand()'}
end

function Square(radius)
    local r = radius or 32
    local function get(x, y)
        return x >= -r and y >= -r and x < r and y < r
    end
    return {create = noop, reload = noop, get = get, lua = 'Square(' .. r .. ')'}
end

function Circle(radius)
    local r = radius or 32
    local function get(x, y)
        return (x * x) + (y * y) < r * r
    end
    return {create = noop, reload = noop, get = get, lua = 'Circle(' .. r .. ')'}
end

function Halfplane()
    local function get(x, y)
        return (x >= 0)
    end
    return {create = noop, reload = noop, get = get, lua = 'Halfplane()'}
end

function Quarterplane()
    local function get(x, y)
        return (x >= 0) and (y >= 0)
    end
    return {create = noop, reload = noop, get = get, lua = 'Quarterplane()'}
end

function Strip(width)
    local n = width or 1
    local function get(x, y)
        return (math.abs(y + 0.25) * 2) < n
    end
    return {create = noop, reload = noop, get = get, lua = 'Strip(' .. n .. ')'}
end

function Cross(width)
    local n = width or 1
    local function get(x, y)
        return (math.abs(x + 0.25) * 2 < n) or (math.abs(y + 0.25) * 2 < n)
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
            return (math.floor(y + 0.5) % 2) == 0
        end
    end
    return {create = noop, reload = noop, get = get, lua = 'Comb()'}
end

function Grid()
    local function geti(x, y)
        return ((x % 2) == 0) or ((y % 2) == 0)
    end
    local function get(x, y)
        return geti(math.floor(x + 0.5), math.floor(y + 0.5))
    end
    return {create = noop, reload = noop, get = get, lua = 'Grid()'}
end

function Checkerboard()
    local function geti(x, y)
        return ((x + y) % 2) == 0
    end
    local function get(x, y)
        return geti(math.floor(x + 0.5), math.floor(y + 0.5))
    end
    return {create = noop, reload = noop, get = get, lua = 'Grid()'}
end

-- 'ratio' is the ratio of the distance of consecutive spirals from the center
-- 'land' is the proportion of terrain that is land
-- Use the reciprocal of some ratio to make the spiral go the other way
function Spiral(ratio, land)
    local r = ratio or 1.4
    local l = land or 0.5
    local lr = math.log(r)
    local function get(x, y)
        local n = (x * x) + (y * y)
        if n < 100 then
            return true
        else
            -- Very irritatingly Lua makes a backwards incompatible
            -- change in arctan between 5.2 and 5.3 that makes it impossible
            -- to write code that is correct in both versions. We are using
            -- 5.2 here.
            return (((math.atan2(y, x) / math.pi) + (math.log(n) / lr)) % 2) < (l * 2)
        end
    end
    return {create = noop, reload = noop, get = get, lua = 'Spiral(' .. r .. ',' .. l .. ')'}
end

-- 'ratio' is the ratio of the distance of consecutive circles from the center
-- 'land' is the proportion of terrain that is land
function ConcentricCircles(ratio, land)
    local r = ratio or 1.4
    local l = land or 0.5
    local lr2 = 2 * math.log(r)
    local function get(x, y)
        local n = (x * x) + (y * y)
        if n < 100 then
            return true
        else
            return ((math.log(n) / lr2) % 1) < l
        end
    end
    return {create = noop, reload = noop, get = get, lua = 'ConcentricCircles(' .. r .. ',' .. l .. ')'}
end

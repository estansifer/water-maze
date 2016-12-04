local rx = {-1, -1, -1, 0, 0, 1, 1, 1}
local ry = {-1, 0, 1, -1, 1, -1, 0, 1}

function Distort(pattern, wavelength, amplitude)
    local pget = pattern.get
    local l = wavelength or 20
    local a = amplitude or 1

    local data

    local function create()
        data = {}
        data.rand = {}
        data.vx = {}
        data.vy = {}
        data.land = {}
        data.pattern = pattern.create()
        return data
    end
    
    local function reload(d)
        data = d
        pattern.reload(data.pattern)
    end

    local function key(x, y)
        return x .. '#' .. y
    end

    -- Returns a random integer from 0 to 8 for each integer (x, y) coordinate
    local function get_rand(x, y)
        local k = key(x, y)
        if data.rand[k] == nil then
            data.rand[k] = math.floor(math.random() * 8)
        end
        return data.rand[k]
    end

    local function fade(t)
        return t * t * t * (t * (t * 6 - 15) + 10)
    end

    local function gradient(i, x, y)
        return rx[i + 1] * x + ry[i + 1] * y
    end

    local function compute_noise(x, y)
        local ix = math.floor(x)
        local iy = math.floor(y)
        x = x - ix
        y = y - iy

        local a = gradient(get_rand(ix, iy),            x, y)
        local b = gradient(get_rand(ix + 1, iy),        x - 1, y)
        local c = gradient(get_rand(ix, iy + 1),        x, y - 1)
        local d = gradient(get_rand(ix + 1, iy + 1),    x - 1, y - 1)

        x = fade(x)
        y = fade(y)
        return a + x * (b - a) + y * (c - a) + x * y * (a + d - b - c)
    end

    local function compute_vx(x, y)
        return (compute_noise(x + 0.01, y) - compute_noise(x - 0.01, y)) / 0.02
    end

    local function compute_vy(x, y)
        return (compute_noise(x, y + 0.01) - compute_noise(x, y - 0.01)) / 0.02
    end

    local function compute(x, y)
        for i = 1, 1 do
            local dx = -compute_vy(x/l, y/l) * a * l / 10
            local dy = compute_vx(x/l, y/l) * a * l / 10
            x = x + dx
            y = y + dy
        end
        return pget(math.floor(x + 0.5), math.floor(y + 0.5))
    end

    local function geti(x, y)
        local k = key(x, y)
        if data.land[k] == nil then
            data.land[k] = compute(x, y)
        end
        return data.land[k]
    end

    local function get(x, y)
        return geti(math.floor(x + 0.5), math.floor(y + 0.5))
    end

    return {
        create = create,
        reload = reload,
        get = get,
        lua = 'Distort(' .. pattern.lua .. ', ' .. l .. ', ' .. a .. ')'
    }
end

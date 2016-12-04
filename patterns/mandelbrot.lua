-- Creates a Mandelbrot set
-- The set is bounded within about -size to size/2 along the x-axis,
-- and -1.2 * size to 1.2 * size along the y-axis.
function Mandelbrot(size)
    local s = size or 100
    local maxiter = 30

    local memo = {}

    local function compute(x0, y0)
        x0 = x0 / s
        y0 = y0 / s
        local iter = 0
        local x, y, x_, y_
        x = x0
        y = y0
        while iter < 100 do
            if x * x + y * y > 4 then
                return false
            end
            x_ = x * x - y * y + x0
            y_ = 2 * x * y + y0
            x = x_
            y = y_
            iter = iter + 1
        end
        return true
    end

    local function geti(x, y)
        if x * x + y * y > 4 * s * s then
            return false
        end
        local key = x .. '#' .. y
        if memo[key] == nil then
            memo[key] = compute(x, y)
        end
        return memo[key]
    end

    local function get(x, y)
        return geti(math.floor(x + 0.5), math.floor(y + 0.5))
    end

    local function create()
        return nil
    end

    local function reload()
        return nil
    end

    return {
        create = create,
        reload = reload,
        get = get,
        lua = 'Mandelbrot(' .. s .. ')'
    }
end

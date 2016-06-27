function Barcode(angle, landthickness, waterthickness)
    local l_ = landthickness or 20
    local w_ = waterthickness or 50
    local l = l_ / (math.sqrt(2) - 1)
    local w = w_ / (math.sqrt(2) - 1)
    local a = angle or 0

    local data

    local function random_thickness(median)
        -- Burr distribution with c = 1, k = 2
        local cdf = math.random()
        return ((1 / math.sqrt(cdf)) - 1) * (median - 3) + 3
    end

    local function create()
        data = {}
        data.bars = {}

        local x = random_thickness(l)
        data.bars[0] = {
                t = - (x / 2),
                dt = x,
                land = true
            }

        data.least_bar = 0
        data.highest_bar = 0

        return data
    end

    local function reload(d)
        data = d
    end

    local function add_low_bar()
        local bar = data.bars[data.least_bar]
        local x
        if bar.land then
            x = random_thickness(w)
        else
            x = random_thickness(l)
        end

        data.least_bar = data.least_bar - 1
        data.bars[data.least_bar] = {
                t = bar.t - x,
                dt = x,
                land = not bar.land
            }
    end

    local function add_high_bar()
        local bar = data.bars[data.highest_bar]
        local x
        if bar.land then
            x = random_thickness(w)
        else
            x = random_thickness(l)
        end

        data.highest_bar = data.highest_bar + 1
        data.bars[data.highest_bar] = {
                t = bar.t + bar.dt,
                dt = x,
                land = not bar.land
            }
    end

    local function get(x, y)
        local t = x * math.sin(a * math.pi / 180) - y * math.cos(a * math.pi / 180)
        while t < data.bars[data.least_bar].t do
            add_low_bar()
        end
        while t > data.bars[data.highest_bar].t do
            add_high_bar()
        end

        -- binary search
        local low, high
        low = data.least_bar
        high = data.highest_bar
        while low + 1 < high do
            local mid = math.floor((low + high) / 2)
            local bar = data.bars[mid]
            if bar.t > t then
                high = mid
            else
                low = mid
            end
        end
        return data.bars[low].land
    end

    return {
        create = create,
        reload = reload,
        get = get,
        lua = 'Barcode(' .. a .. ',' .. l_ .. ',' .. w_ .. ')'
    }
end

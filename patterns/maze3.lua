function Maze3(t, v)
    if v == nil then
        v = true
    end

    local max_attempts = 1000
    local initial_range = 100

    -- do not change this number unless you know what you are doing
    -- values greater than 0.59274621 are fine
    -- lower than that is bad
    -- https://en.wikipedia.org/wiki/Percolation_threshold
    local criticalvalue = 0.59274621
    local threshhold = t or 0.6
    local verify = v

    -- Safeguard to make sure we don't try to do the impossible
    if (threshhold < criticalvalue + 0.001) and verify then
        threshhold = 0.6
    end

    local data

    local function compute(x, y)
        if x > -2 and x < 1 and y > -2 and y < 1 then
            return true
        end
        return math.random() < threshhold
    end

    local function get(x, y)
        local key = x .. '#' .. y
        if data.values[key] == nil then
            data.values[key] = compute(x, y)
        end
        return data.values[key]
    end

    local function floodfill(visited, x, y)
        local n = initial_range
        if x < -n or x > n or y < -n or y > n or visited[x][y] then
            return
        end
        if get(x, y) then
            visited[x][y] = true
            floodfill(visited, x - 1, y)
            floodfill(visited, x + 1, y)
            floodfill(visited, x, y - 1)
            floodfill(visited, x, y + 1)
        end
    end

    local function verify_ok()
        if not verify then
            return true
        end

        local n = initial_range
        local visited = {}
        for x = -n, n do
            visited[x] = {}
        end
        floodfill(visited, 0, 0)

        local left, right, top, bottom

        for i = -n, n do
            left = left or visited[-n][i] 
            right = right or visited[n][i]
            top = top or visited[i][-n]
            bottom = bottom or visited[i][n]
        end

        return left and right and top and bottom
    end

    local function create()
        data = {}
        local num_attempts = 0
        repeat
            data.values = {}
            num_attempts = num_attempts + 1
        until verify_ok() or num_attempts >= max_attempts

        return data
    end

    local function reload(d)
        data = d
    end

    return {
        create = create,
        reload = reload,
        get = get,
        lua = 'Maze3(' .. threshhold .. ',' .. tostring(verify) .. ')'
    }
end

local queue = require "queue"

-- Based on Wilson's algorithm
local function maze2()
    local dirs = {
        {dx = 1, dy = 0},
        {dx = -1, dy = 0},
        {dx = 0, dy = 1},
        {dx = 0, dy = -1}
    }
    if global.maze2 == nil then
        global.maze2 = {
            land            = {},
            nearland        = {},
            nearishland     = {},
            pending         = {},
            pendingsum      = 0,
            pendingr        = 0,
            nearest         = 0
        }
    end
    local land              = global.maze2.land
    local nearland          = global.maze2.nearland
    local nearishland       = global.maze2.nearishland
    local pending           = global.maze2.pending
    local pendingsum        = global.maze2.pendingsum
    local pendingr          = global.maze2.pendingr
    local nearest           = global.maze2.nearest

    local function key(x, y)
        -- Fuck you, Lua! Took me an hour to debug this. Without the following lines, the
        -- code enters an infinite loop and Factorio freezes when starting a new game.
        if x == 0 then
            x = 0
        end
        if y == 0 then
            y = 0
        end

        return x .. '#' .. y
    end

    local function makeland(x, y)
        land[key(x, y)] = true
        nearland[key(x, y)] = true
        nearland[key(x - 1, y)] = true
        nearland[key(x + 1, y)] = true
        nearland[key(x, y - 1)] = true
        nearland[key(x, y + 1)] = true
        nearishland[key(x - 1, y - 1)] = true
        nearishland[key(x + 1, y - 1)] = true
        nearishland[key(x - 1, y + 1)] = true
        nearishland[key(x + 1, y + 1)] = true
    end

    makeland(0, 0)
    makeland(-1, 0)
    makeland(0, -1)
    makeland(-1, -1)

    local function weight(x, y)
        return 1 / math.sqrt(math.abs(x * x) + math.abs(y * y) + 4)
    end

    local function impend(x, y)
        local k = key(x, y)
        if (not nearishland[k]) and (not nearland[k]) and (pending[k] == nil) then
            local w = weight(x, y)
            -- db('Adding ' .. k)
            pending[k] = {x = x, y = y, w = w}
            pendingsum = pendingsum + w
            if x * x + y * y < nearest * nearest then
                nearest = math.sqrt(x * x + y * y)
            end
        end

        global.maze2.pendingsum = pendingsum
        global.maze2.nearest = nearest
    end

    local function update_pending()
        for k, _ in pairs(pending) do
            if nearishland[k] or nearland[k] then
                pending[k] = nil
            end
        end

        pendingsum = 0
        local count = 0
        nearest = 1000000000
        for _, v in pairs(pending) do
            count = count + 1
            pendingsum = pendingsum + v.w
            local n = v.x * v.x + v.y * v.y
            if n < nearest then
                nearest = n
            end
        end
        nearest = math.sqrt(nearest)

        local n = pendingr
        while pendingsum < 5 do
            for i = -n, n do
                impend(i, -n)
                impend(i, n)
                impend(-n, i)
                impend(n, i)
            end
            pendingr = pendingr + 1
            n = pendingr
        end

        global.maze2.pendingsum = pendingsum
        global.maze2.pendingr = pendingr
        global.maze2.nearest = nearest
    end

    local function random_direction(x, y)
        if math.random() < 0.95 then
            return dirs[1 + math.floor(math.random() * 4)]
        else
            if math.random() < 0.5 then
                if x < 0 then
                    return {dx = 1, dy = 0}
                else
                    return {dx = -1, dy = 0}
                end
            else
                if y < 0 then
                    return {dx = 0, dy = 1}
                else
                    return {dx = 0, dy = -1}
                end
            end
        end
    end

    local function fill_shortest_path(path, x, y)
        local q = queue.empty()
        local visited = {}

        q.push({x = x, y = y})
        local p
        while true do
            p = q.pop()
            local k = key(p.x, p.y)
            if path[k] and (visited[k] == nil) then
                visited[k] = true
                if nearland[k] then
                    break
                end
                for _, d in pairs(dirs) do
                    q.push({x = p.x + d.dx, y = p.y + d.dy, prev = p})
                end
            end
        end

        while not (p == nil) do
            makeland(p.x, p.y)
            p = p.prev
        end
    end

    local function diffuse_from(x, y)
        -- db ('Diffusing ' .. x .. ' ' .. y)
        local n = {}
        local k
        local cx, cy
        cx, cy = x, y
        
        while true do
            k = key(cx, cy)
            if nearland[k] then
                break
            end
            d = random_direction(cx, cy)
            cx = cx + d.dx
            cy = cy + d.dy
            n[k] = key(cx, cy)
        end

        path = {}
        k = key(x, y)
        while not (k == nil) do
            path[k] = true
            k = n[k]
        end

        fill_shortest_path(path, x, y)
    end

    local function diffuse()
        update_pending()
        r = math.random() * pendingsum

        for k, v in pairs(pending) do
            r = r - v.w
            if r < 0 then
                diffuse_from(v.x, v.y)
                break
            end
        end
    end

    local function get(x, y)
        while math.sqrt(x * x + y * y) + 5 > nearest do
            diffuse()
        end
        return land[key(x, y)] == true
    end

    return {get = get, lua = 'maze2()'}
end

return maze2

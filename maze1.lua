local uf = require "union-find"

local append = table.insert

local function maze1()
    -- Small adjustment to connectedness of land. Values from 0 to 1 ok.
    local connectedness = 0.4

    local dirs = {
        {dx = 1, dy = 0},
        {dx = -1, dy = 0},
        {dx = 0, dy = 1},
        {dx = 0, dy = -1}
    }
    local fibs = {1, 2, 3, 5, 8, 13, 21, 34, 55}

    if global.maze1 == nil then
        global.maze1 = {
            values          = {},
            group_parents   = nil,
            x1              = -1,
            y1              = -1,
            x2              = 0,
            y2              = 0
        }
    end
    local values            = global.maze1.values
    local group             = uf.create(global.maze1.group_parents)
    local x1                = global.maze1.x1
    local x2                = global.maze1.x2
    local y1                = global.maze1.y1
    local y2                = global.maze1.y2

    local function save()
        global.maze1.group_parents = group.get_parents()
        global.maze1.x1 = x1
        global.maze1.x2 = x2
        global.maze1.y1 = y1
        global.maze1.y2 = y2
    end

    local function key(x, y)
        return x .. '#' .. y
    end

    local function fibdigits(n, k)
        local ans = {}
        for i = 1, n do
            local f = fibs[n + 1 - i]
            ans[i] = (k >= f)
            if ans[i] then
                k = k - f
            end
        end
        return ans
    end

    local function random(n)
        while n >= #fibs do
            append(fibs, fibs[#fibs] + fibs[#fibs - 1])
        end
        return math.floor(math.random() * fibs[n + 1])
    end

    local function assign(x, y, value)
        local k = key(x, y)
        values[k] = value

        for _, d in ipairs(dirs) do
            local k2 = key(x + d.dx, y + d.dy)
            if value == values[k2] then
                group.union(k, k2)
            end
        end
    end

    local function expand()
        -- db ('expand x1 = ' .. x1 .. ', y1 = ' .. y1)
        local a = {}

        for x = x1, x2 do
            local k = key(x, y1)
            local p = {x = x, y = y1 - 1}
            local b = a[group.get(k)]
            -- db (x .. ' ' .. y1 .. ' ' .. tostring(values[k]) .. ' ' .. tostring(values[key(x - 1, y1)]))
            if values[k] == values[key(x - 1, y1)] then
                append(b[#b], p)
            else
                if b == nil then
                    b = {}
                    a[group.get(k)] = b
                end
                append(b, {p})
            end
        end

        for x = x1, x2 do
            local k = key(x, y2)
            local p = {x = x, y = y2 + 1}
            local b = a[group.get(k)]
            if values[k] == values[key(x - 1, y2)] then
                append(b[#b], p)
            else
                if b == nil then
                    b = {}
                    a[group.get(k)] = b
                end
                append(b, {p})
            end
        end

        for y = y1, y2 do
            local k = key(x1, y)
            local p = {x = x1 - 1, y = y}
            local b = a[group.get(k)]
            if values[k] == values[key(x1, y - 1)] then
                append(b[#b], p)
            else
                if b == nil then
                    b = {}
                    a[group.get(k)] = b
                end
                append(b, {p})
            end
        end

        for y = y1, y2 do
            local k = key(x2, y)
            local p = {x = x2 + 1, y = y}
            local b = a[group.get(k)]
            if values[k] == values[key(x2, y - 1)] then
                append(b[#b], p)
            else
                if b == nil then
                    b = {}
                    a[group.get(k)] = b
                end
                append(b, {p})
            end
        end
        
        for k, b in pairs(a) do
            -- db("Group " .. k .. " has " .. #b .. " segments")
            local r
            local positive
            repeat
                positive = not values[k]
                r = {}
                for _, c in ipairs(b) do
                    append(r, random(#c))
                    if r[#r] > 0 then
                        positive = true
                        if not values[k] and math.random() < connectedness then
                            r[#r] = 0
                        end
                    end
                end
            until positive
            for i = 1, #r do
                local c = b[i]
                -- db("  Segment " .. i .. " has " .. #c .. " parts")
                local rr = fibdigits(#c, r[i])
                for j = 1, #c do
                    -- db("    " .. i .. " " .. j .. " " .. c[j].x .. " " .. c[j].y .. " " .. tostring(rr[j]) .. " " .. tostring(rr[j] == values[k]))
                    assign(c[j].x, c[j].y, rr[j] == values[k])
                end
            end
        end

        assign(x1 - 1, y1 - 1, math.random() < 0.5)
        assign(x1 - 1, y2 + 1, math.random() < 0.5)
        assign(x2 + 1, y1 - 1, math.random() < 0.5)
        assign(x2 + 1, y2 + 1, math.random() < 0.5)

        x1 = x1 - 1
        x2 = x2 + 1
        y1 = y1 - 1
        y2 = y2 + 1
        save()
    end

    local function get(x, y)
        k = key(x, y)
        while true do
            v = values[k]
            if v == nil then
                expand()
            else
                return v
            end
        end
    end

    if values[key(0, 0)] == nil then
        assign(0, 0, true)
        assign(-1, 0, true)
        assign(0, -1, true)
        assign(-1, -1, true)
        save()
    end

    return {get = get, lua = 'maze1()'}
end

return maze1

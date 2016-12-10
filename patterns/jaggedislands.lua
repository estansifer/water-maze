function JaggedIslands(landratio)
    local lr = landratio or 0.5
    local l = math.sqrt(lr)
    local dirs = {
        {dx = 1, dy = 0},
        {dx = -1, dy = 0},
        {dx = 0, dy = 1},
        {dx = 0, dy = -1}
    }

    local data

    local function key(x, y)
        if x == 0 then
            x = 0
        end
        if y == 0 then
            y = 0
        end

        return x .. '#' .. y
    end

    local function create()
        data = {
            groups = {},
            xy2group = {}
        }

        return data
    end

    local function reload(d)
        data = d
    end

    local choices = {}

    local function which_group(x, y, keys)
        local k = key(x, y)

        if data.xy2group[k] == nil then
            if keys == nil then
                keys = {}
            end

            if keys[k] then
                group = {
                    id = (#(data.groups)) + 1,
                    sx = 0,
                    sy = 0,
                    count = 0,
                    done = false
                }
                data.groups[group.id] = group
                data.xy2group[k] = group.id
                return group.id
            end

            dir = dirs[1 + math.floor(math.random() * 4)]
            keys[k] = true
            gid = which_group(x + dir.dx, y + dir.dy, keys)
            group = data.groups[gid]
            group.sx = group.sx + x
            group.sy = group.sy + y
            group.count = group.count + 1
            data.xy2group[k] = gid
        end

        return data.xy2group[k]
    end

    local function floodfill(x, y, gid, visited)
        local k = key(x, y)

        if visited[k] == nil then
            visited[k] = true
            gid2 = which_group(x, y)
            if gid == gid2 then
                for _, d in ipairs(dirs) do
                    floodfill(x + d.dx, y + d.dy, gid, visited)
                end
            end
        end
    end

    local function dofloodfill(x, y)
        local gid = which_group(x, y)
        local group = data.groups[gid]
        if not group.done then
            floodfill(x, y, gid, {})
            print ("Group " .. gid .. " has " .. group.count .. " members.")
        end
        group.done = true
        return group.count
    end

    local function get(x, y)
        local x_ = math.floor(x * l)
        local y_ = math.floor(y * l)
        local gid = which_group(x_, y_)
        local count = dofloodfill(x_, y_)

        local group = data.groups[gid]
        local mx = group.sx / group.count
        local my = group.sy / group.count
        local x__ = math.floor(x + mx * (1 - 1 / l))
        local y__ = math.floor(y + my * (1 - 1 / l))
        local gid__ = which_group(x__, y__)
        return gid == gid__
    end

    return {
        create = create,
        reload = reload,
        get = get,
        lua = 'JaggedIslands(' .. lr .. ')'
    }
end

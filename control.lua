require "util"

require "config"

local terrain_pattern_get = nil

local append = table.insert

local msg = 0

function db(s)
    game.player.print('Debug [' .. msg .. ']    ' .. s)
    msg = msg + 1
end

local function scan_near_player(player, radius)
    local x = player.position.x
    local y = player.position.y
    player.force.chart(player.surface, {{x - radius, y - radius}, {x + radius, y + radius}})
end

local function big_scan(event)
    if (event.tick % 600) == 0 then
        local ps = game.players
        if (ps ~= nil) and (ps[1] ~= nil) then
            scan_near_player(ps[1], 200)
        end
    end
end

local function make_chunk(event)
    local c = global.saved_config
    if c == nil or c.disable_water or terrain_pattern_get == nil then
        return
    end
    -- Bug fix from EldVarg
    if event.surface.name ~= "nauvis" then
        return
    end

    local x1 = event.area.left_top.x
    local y1 = event.area.left_top.y
    local x2 = event.area.right_bottom.x
    local y2 = event.area.right_bottom.y
    local surface = event.surface
    local k = 5

    tiles = {}

    for x = x1 - k, x2 + k do
        for y = y1 - k, y2 + k do
            if (not c.check_for_instant_death) or (x * x + y * y > 3) then
                local old = surface.get_tile(x, y).name
                local new = terrain_pattern_get(x, y)
                if new == "land" then
                    if old == "water" or old == "deepwater" then
                        append(tiles, {name = "grass", position = {x, y}})
                    end
                else
                    if not (new == old) then
                        append(tiles, {name = new, position = {x, y}})
                    end
                end
            end
        end
    end

    surface.set_tiles(tiles)
end

local function player_created(event)
    local c = global.saved_config
    if c ~= nil and c.start_with_car then
        local player = game.players[event.player_index]
        player.character.insert{name = "coal", count = 50}
        player.character.insert{name = "car", count = 1}
    end
end

local function on_load(event)
    local c = global.saved_config
    if c ~= nil then
        if (terrain_pattern_get == nil) then
            local s = 'return (' .. c.tp_lua .. ')'
            local tp = (load(s))()
            tp.reload(c.tp_data)
            terrain_pattern_get = tp.get
        end
        if c.big_scans then
            script.on_event(defines.events.on_tick, big_scan)
        end
        script.on_event(defines.events.on_chunk_generated, make_chunk)
        script.on_event(defines.events.on_player_created, player_created)
    end
end

local function on_init(event)
    global.saved_config     = config
    config.tp_data          = config.terrain_pattern.create()
    config.tp_lua           = config.terrain_pattern.lua
    terrain_pattern_get     = config.terrain_pattern.get
    config.terrain_pattern  = nil
    on_load(nil)
end

script.on_init(on_init)
script.on_load(on_load)

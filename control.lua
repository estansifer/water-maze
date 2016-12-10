require "util"
require "config"

local terrain_pattern_get = nil

local append = table.insert

local function make_chunk(event)
    local c = global.saved_config
    if c == nil or terrain_pattern_get == nil or event.surface.name ~= "nauvis" then
        -- "nauvis" change from EldVarg, to make it compatible with Factorissimo
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

local function on_load(event)
    local c = global.saved_config
    if c ~= nil then
        if (terrain_pattern_get == nil) then
            local s = 'return (' .. c.tp_lua .. ')'
            local tp = (load(s))()
            tp.reload(c.tp_data)
            terrain_pattern_get = tp.get
        end
        script.on_event(defines.events.on_chunk_generated, make_chunk)
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

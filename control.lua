require "defines"
require "util"
require "patterns"

--[[
        Configuration (information below)
]]

local extra_options = {
    start_with_car = false,
    disable_water = false,
    big_scans = false
}

local watercolor = "blue"

local pattern

-- pattern = maze1()
-- pattern = maze2()                -- This is the best of the three maze algorithms
-- pattern = maze3()
-- pattern = cross()
-- pattern = comb()
-- pattern = grid()
-- pattern = islands(64, 64, 2)     -- Do not use chunkify with this
-- pattern = island(32)             -- Do not use chunkify with this
-- pattern = roundisland(32)        -- Do not use chunkify with this

pattern = maze2()

pattern = chunkify(pattern, 32)

-- pattern = safety(pattern)

pattern = add_land_boundary(pattern, watercolor)

--[[
        End of configuration

        In most configurations, you will want to turn resource generation WAY up, probably to
        maximum on all settings, to compensate for the decreased land area and inaccessibility.
        You may want to turn down enemy spawns to compensate for inaccessibility.

        watercolor:
            "blue" or "green"

        First, define a pattern from one of the examples given.
            maze1 -- builds a weird maze
            maze2 -- a very nice looking maze algorithm which builds a DLA. It is based on
                Wilson's algorithm and involves diffusion. Definitely the best of the three
                maze algorithms.
            maze3 -- a simple algorithm that gives very irregular and random shapes. It is
                related to percolation theory.
            cross
            comb
            grid
            islands
            island -- makes a single island of the specified radius (don't use)
            roundisland -- makes a single island of the specified radius (don't use)

        For maze2 (and to a much lesser extent with maze1) you may run into performance
        problems when exploring new territory far from the origin. This is especially true
        if your chunkify parameter is low.

        You can modify patterns with
            union(pattern1, pattern2)
            intersection(pattern1, pattern2)
            translate(pattern, dx, dy) -- dx, dy must be integers
            chunkify(pattern, factor) -- factor need not be integer
        For example, unioning with an island pattern guarantees a large land area at the origin.

        Second, optionally pass it through "chunkify" to change the resolution of the pattern.
        This zooms in on the pattern by the specified amount. If you don't do this, there will
        likely be no land area large enough to build any buildings on, or other bad behavior
        might happen. An absolute minimum amount might be 2 to 4. I like 16 to 32. Smaller values
        make it hard to find adequate land.

        Third, optionally pass the pattern through the "safety" function. This can be done
        before chunkifying. This creates a small land area at the origin to prevent death due
        to spawing in water.

        Fourth, pass through the add_land_boundary function. Thus function assumes that "true"
        corresponds to land and "false" corresponds to water, and that all segments of land and
        water are at least two tiles wide.
]]

-- Store the pattern that was used to originally create the game world, ignoring changes
-- to the configuration made since then.
local original_pattern = nil

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

local function on_tick(event)
    if (event.tick % 600) == 0 then
        local ps = game.players
        if (ps ~= nil) and (ps[1] ~= nil) then
            scan_near_player(ps[1], 200)
        end
    end
end

-- Get a string representation of the original pattern used when this game was first
-- created so that it preserves the original configuration even if changes were made later.
local function on_load(event)
    if original_pattern == nil then
        if global.pattern_lua == nil then
            script.on_event(defines.events.on_chunk_generated, nil)
        else
            local s = 'return (' .. global.pattern_lua .. ').get'
            original_pattern = (load(s))()
        end
    end
    extra_options = global.extra_options or {}
    if extra_options.big_scans then
        script.on_event(defines.events.on_tick, on_tick)
    end
    if extra_options.disable_water then
        script.on_event(defines.events.on_chunk_generated, nil)
    end
end

-- Save a string representation of the pattern being used in the save file
local function on_init(event)
    original_pattern = pattern.get
    global.pattern_lua = pattern.lua
    global.extra_options = extra_options
    on_load(nil)
end

local function make_chunk(event)
    local x1 = event.area.left_top.x
    local y1 = event.area.left_top.y
    local x2 = event.area.right_bottom.x
    local y2 = event.area.right_bottom.y
    local surface = event.surface
    local k = 5

    tiles = {}

    for x = x1 - k, x2 + k do
        for y = y1 - k, y2 + k do
            local old = surface.get_tile(x, y).name
            local new = original_pattern(x, y)
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

    surface.set_tiles(tiles)
end

local function player_created(event)
    local player = game.get_player(event.player_index)
    if extra_options.start_with_car then
        player.character.insert{name = "coal", count = 50}
        player.character.insert{name = "car", count = 1}
    end
end

script.on_init(on_init)
script.on_load(on_load)
script.on_event(defines.events.on_chunk_generated, make_chunk)
script.on_event(defines.events.on_player_created, player_created)

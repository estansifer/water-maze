require "patterns/patterns"

--[[
        Configuration (information below)
]]

local watercolor = "blue"

local pattern = Zoom(Maze2(), 16)
-- You might want to change the 16 above to a larger number to make it more playable

-- Some fun patterns!:
-- local pattern = Islandify(Maze3(), 16, 8, 4)
-- local pattern = Union(Zoom(Cross(), 16), ConcentricCircles(1.3))
-- local pattern = Intersection(Zoom(Maze3(), 32), Zoom(Grid(), 2))
-- local pattern = Union(Spiral(1.8, 0.6), Intersection(Zoom(Maze3(), 16), Zoom(Grid(), 2)))
-- local pattern = Union(Union(Zoom(Maze3(0.2, false), 31), Zoom(Maze3(0.05, false), 57)), Zoom(Maze3(0.6), 8))

config = {
    start_with_car      = false,
    disable_water       = false,
    big_scans           = false,
    terrain_pattern     = TerrainPattern(pattern, watercolor)
}

-- Possible patterns and pattern combinators:
-- pattern = Maze1()
-- pattern = Maze2()                -- This is the best of the three maze algorithms
-- pattern = Maze3()
-- pattern = Strip()
-- pattern = Cross()
-- pattern = Comb()
-- pattern = Grid()
-- pattern = Spiral(1.5, 0.5)       -- Zoom is not necessary with this
-- pattern = ConcentricCircles(1.5, 0.5)        -- Zoom is not necessary with this
-- pattern = Island(32)             -- Zoom is not necessary with this
-- pattern = Roundisland(32)        -- Zoom is not necessary with this
-- pattern = Halfplane()            -- Zoom is not necessary with this
-- pattern = Quarterplane()         -- Zoom is not necessary with this
-- pattern = Islands(64, 64, 4)     -- Zoom is not necessary with this
-- pattern = Islandify(pattern, 64, 64, 4) -- Zoom is not necessary with this
-- pattern = Union(pattern1, pattern2)
-- pattern = Intersection(pattern1, pattern2)
-- pattern = Zoom(pattern, 10)
-- pattern = TerrainPattern(pattern, watercolor) -- Use at the end

--[[
        In most configurations, you will want to turn resource generation WAY up, probably to
        maximum on all settings, to compensate for the decreased land area and inaccessibility.
        You may want to turn down enemy spawns to compensate for inaccessibility.

        watercolor:
            "blue" or "green"

        First, define a pattern from one of the examples given.
            Maze1 -- builds a weird maze
            Maze2 -- a very nice looking maze algorithm which builds a DLA. It is based on
                Wilson's algorithm and involves diffusion. Definitely the best of the three
                maze algorithms.
            Maze3 -- a simple algorithm that gives very irregular and random shapes. It is
                related to percolation theory.
            Strip
            Cross
            Comb
            Grid
            Islands
            Island -- makes a single island of the specified radius (don't use)
            Roundisland -- makes a single island of the specified radius (don't use)
            Halfplane
            Quarterplane

        For Maze2 (and to a much lesser extent with Maze1) you may run into performance
        problems when exploring new territory far from the origin. This is especially true
        if your zoom factor is low.

        You can modify patterns with
            Islandify(pattern, r, w, l)
            Union(pattern1, pattern2)
            Intersection(pattern1, pattern2)
            Translate(pattern, dx, dy) -- dx, dy must be integers
            Zoom(pattern, factor) -- factor need not be integer
        For example, unioning with an island pattern guarantees a large land area at the origin.

        Second, optionally pass it through "Zoom" to change the resolution of the pattern.
        This zooms in on the pattern by the specified amount. If you don't do this, there will
        likely be no land area large enough to build any buildings on, or other bad behavior
        might happen. An absolute minimum amount might be 2 to 4. I like 16 to 32. Smaller values
        make it hard to find adequate land.

        Fourth, pass through the TerrainPattern function. Thus function assumes that "true"
        corresponds to land and "false" corresponds to water, and that all segments of land and
        water are at least two tiles wide.
]]

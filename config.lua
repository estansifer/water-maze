require "patterns/patterns"

--[[
        Configuration (information below)
]]

local watercolor = "blue"

local pattern = Zoom(Maze2(), 16)
-- You might want to change the 16 above to a larger number to make it more playable

-- Some fun patterns!:
-- local pattern = SquaresAndBridges(64, 32, 4) -- the most popular pattern, probably
-- local pattern = Islandify(Maze3(), 16, 8, 4)
-- local pattern = Union(Zoom(Cross(), 16), ConcentricCircles(1.3))
-- local pattern = Intersection(Zoom(Maze3(), 32), Zoom(Grid(), 2))
-- local pattern = Union(Spiral(1.6, 0.6), Intersection(Zoom(Maze3(0.5, false), 8), Zoom(Grid(), 2)))
-- local pattern = Union(Union(Zoom(Maze3(0.25, false), 31), Zoom(Maze3(0.1, false), 97)), Zoom(Maze3(0.6), 11))
-- local pattern = Union(Barcode(10, 5, 20), Barcode(60, 5, 30))
-- local pattern = Union(Zoom(JaggedIslands(0.3), 32), Union(Barcode(0, 6, 50), Barcode(90, 6, 50)))

config = {
    start_with_car      = false,
    disable_water       = false,
    big_scans           = false,
    check_for_instant_death = true,
    terrain_pattern     = TerrainPattern(pattern, watercolor)
}

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
            SquaresAndBridges
            Square
            Circle
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

# Water Maze

a [Factorio](http://factorio.com) mod by Eric Stansifer

Hosted at `https://github.com/estansifer/water-maze/`

This mod changes the distribution of land and water at the start of a new game.

## Important Notes

 * To configure the mod, edit the configuration section at the top of `control.lua`. There
 are instructions immediately below the configuration section.
 * In most configurations, resources are much rarer and harder to reach than in the
 vanilla game. It is strongly recommended to turn resource generation WAY up, probably to
 maximum on size and richness at least. You may also want to turn enemy spawns down.
 * The various maze generators can be computationally heavy when exploring new territory
 far from the origin. This is most true for maze2, which may cause problems on ultra large
 maps.
 * Thanks to some deep magic, the mod remembers the settings that it had when you started a
 new game. If you change settings you can still reload old games and they will continue to
 generate terrain according to the original settings and ignore the new ones. This allows you
 to have multiple concurrent games going on with different settings. This also allows multiplayer
 to work even if different players have different settings active (host's settings dominate).
 Also this mod should have no effect if the game was started with it disabled.
 * The map setting for water size does not have a direct effect on the game. The map setting
 for water does affect the distribution of dry/wet biomes and in particular the amount of
 trees, neither of which the mod modifies.
 * You can choose between blue and green water!
 * This mod should be considered unstable and may contain bugs. In particular, version changes
 are likely to be incompatible; I suggest completing any games started with an earlier version
 of the mod before upgrading.
 * Mod has been tested on multiplayer.

## Unimportant Notes

 * The maze1 generation algorithm guarantees that all landmasses are infinite in size. With
 probability 1, all land is accessible from the starting location. The algorithm will never
 generate 2x2 regions of solid land or solid water (other than the origin), making it quite
 hard to find places to build a factory. The algorithm will sometimes make loops. This algorithm
 tends to align land in rings centered on the origin. Internally, the algorithm uses the
 [union-find](https://en.wikipedia.org/wiki/Disjoint-set_data_structure) algorithm and also
 [base Fibonacci](https://en.wikipedia.org/wiki/Zeckendorf%27s_theorem). This maze generation
 algorithm was wholly devised by me from scratch.
 * The maze2 generation algorithm guarantees that all land is accessible from the origin and
 that the landmass is infinite in size. This algorithm makes a sparser maze than the previous,
 but will never generate a 3x3 region of water. The algorithm infrequently generates 2x2 regions
 of land, making it quite hard to find places to build a factory. This algorithm likes to make
 straight paths, making it the most suitable for train networks of the three maze algorithms,
 and generally makes the nicest looking mazes. Internally, the algorithm builds a
 [Diffusion-limited aggregate](https://en.wikipedia.org/wiki/Diffusion-limited_aggregation) and
 is based on Wilson's algorithm for maze generation. The diffusion process is quite slow but a
 small advective bias towards the origin is used to prevent the algorithm from taking an
 extremely long time in the worst case.
 * The maze3 generation algorithm simply randomly makes each chunk land or water (the former
 with 60% probability). The algorithm guarantees that from the starting square you can travel at
 least 100 chunks north, east, south, and west. Since 60% is above the critical
 [percolation threshold](https://en.wikipedia.org/wiki/Percolation_threshold#Thresholds_on_Archimedean_lattices)
 59.27% for site percolation on a square lattice, it is very likely (but not guaranteed) that
 the starting landmass is infinite. This algorithm frequently generates loops and inaccessible
 islands. This algorithm frequently generates large and irregular chunks of land, making it
 relatively easy to find places to build a factory. The boundary between land and water is
 almost a fractal (it would be a fractal if the probability of land were exactly the critical
 threshold, but in that case land masses would not be infinite).

## Screenshots

[screenshots](https://imgur.com/a/wptLh)

The screenshots show some example terrain generation algorithms possible with this mod; other
variations are possible. See the configuration section at the top of `control.lua` for more
information.

The screenshot of the example maze1 output is from an earlier version that did not guarantee
that no 2x2 chunks of land or water were generated.

## License

MIT license

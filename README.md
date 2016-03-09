# Water Maze

a [Factorio](http://factorio.com) mod by Eric Stansifer

Hosted at `https://github.com/estansifer/water-maze/`

This mod changes the distribution of land and water at the start of a new game.

## Important Notes

 * To configure the mod, edit the configuration section at the top of `control.lua`. There
 are instructions immediately below the configuration section.
 * In most configurations, resources are much rarer and harder to reach than in the
 vanilla game. It is strongly recommended to turn resource generation WAY up, probably to
 maximum on all settings. You may also want to turn enemy spawns down.
 * The various maze generators can be computationally heavy when exploring new territory
 far from the origin. This is most true for maze2, which may cause problems on ultra large
 maps.
 * Thanks to some deep magic, the mod remembers the settings that it had when you started a
 new game. If you change settings you can still reload old games and they will continue to
 generate terrain according to the original settings and ignore the new ones. This allows you
 to have multiple concurrent games going on with different settings. This also allows multiplayer
 to work even if different players have different settings active (host's settings dominate).
 Also this mod should have no effect if the game was started with it disabled.
 * The map setting for water size does not have a direct effect on the game. If Factorio spawns
 water at a location where this mod wishes to place land, it will be replaced with grass; so
 any large featureless expanses of grass can be thought of as ancient lake beds. The map
 setting for water does affect the distribution of dry/wet biomes and in particular the amount
 of trees, neither of which the mod modifies.
 * You can choose between blue and green water!
 * This mod should be considered unstable and may contain bugs. In particular, version changes
 are likely to be incompatible; I suggest completing any games started with an earlier version
 of the mod before upgrading.

## Screenshots

[screenshots](https://imgur.com/a/wptLh)

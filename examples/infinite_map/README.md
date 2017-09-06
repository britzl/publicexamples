# Infinite map
Infinite tilemap using perlin noise. The tilemap is sized to cover the screen with a one tile margin. Every time the player passes over the edge of two tiles the tilemap contents will get updated. The tilemap position is kept more or less fixed at origo and only moving within the range of the size of a single tile.

The player and enemies on the map are kept parented to a root game object and they are moving freely. The root game object is offset against the player position to keep the player centered on the tilemap.

## Try it!
http://britzl.github.io/publicexamples/infinite_map/index.html

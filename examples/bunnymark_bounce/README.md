# bunnymark
Classic example of engine performance when animating and rendering many sprites.

The bunnies are animated in Lua using the update() lifecycle function. Animating in the update() function will be a lot slower than using the go.animate() functionality built into the engine.

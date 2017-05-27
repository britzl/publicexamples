# Draw pixels
This example shows how to create and modify a texture. The texture is created using the [buffer API](http://www.defold.com/ref/dmBuffer/) provided by Defold. Some important notes:

1. You need to keep in mind that you are changing the texture (atlas), not an individual image assigned to a sprite. This means that if you intend to change a specific image within the texture (atlas) you need to know where within the texture the image you wish to change exists. In this example the atlas contains only a single texture to simplify things.
2. Even if you work with only a single image atlas you also need to take into account that the texture will be scaled to the nearest power of two dimensions, meaning that a 640x1136 image will have a texture size of 1024x2048.

## Try it
http://britzl.github.io/publicexamples/draw_pixels/index.html

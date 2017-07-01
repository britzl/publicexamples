# Camera implementation as a game object
This example shows how to replace the built in camera component with one created as a game object (camera.go). The camera game object will every frame send a "set_view_projection" message to the render script. The message will be identical to the one sent by the camera component, with the exception of the id being set to the id of the camera game object.

The example also shows a render script with support for split screen. The render script will split the screen horizontally into as many slices as there are cameras.

https://forum.defold.com/t/allow-multiple-cameras-to-be-active-at-once-properly-send-camera-id-when-communicating/2634

## Orthographic Camera API
For a more up-to-date and easier to use orthographic camera please check the [defold-orthographic](https://github.com/britzl/defold-orthographic) library project.

## Try it!
http://britzl.github.io/publicexamples/camera/index.html

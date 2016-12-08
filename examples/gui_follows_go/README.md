# GUI follows GO
This example shows how to make gui nodes follow game objects. This is achieved through a gui scene with Adjust Mode set to Disabled, a separate material (detached_gui.material) and a custom render script that draws the detached_gui predicate at the same time as sprites.

Example created based on the following forum question: https://forum.defold.com/t/another-quastion-about-gui/3624

## How to test this yourself
Set `gui_follows_go.render` and `gui_follows_go.collection` under the Bootstrap section of game.project.

## Try the HTML demo
http://britzl.github.io/publicexamples/gui_follows_go/index.html
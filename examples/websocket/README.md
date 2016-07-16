# Websocket example
This example shows how to connect to a websocket. The example is based on the [lua-websocket](https://github.com/lipp/lua-websockets) project and also additional files from the [LuaSocket](https://github.com/diegonehab/luasocket) project.

The client implementations provided by lua-websocket include synchronous websockets (ie blocking), coroutine based websockets using [copas](https://github.com/keplerproject/copas) and asynchronous websockets using [lua-ev](https://github.com/brimworks/lua-ev). All three of the implementations will take care of websocket handshake and encode/decode of websocket frames.

The synchronous implementation does not work very well in a game where it's not acceptable to block execution while sending or receiving data on a websocket. The coroutine based websocket using copas will work well in a game, but it adds another dependency. Finally, the lua-ev based websockets require C libraries to function, which currently is not possible in a cross platform way in Defold.
This means that the copas based client is the best bet in a Defold game. However, this solution has its drawbacks as we will see in the section below.

# Some very important notes and gotchas
## 1. Emscripten and websockets
Emscripten will automatically create websocket connections when creating sockets. Emscripten will take care of the websocket handshake and encode/decode of the frames. Since all three of the lua-websocket solutions also will attempt to take care of handshake and encode/decode it means that all of them will fail in a Defold game built for HTML5.

This example provides a fourth client implementation (examples/websocket/client_async.lua) that is coroutine based using non blocking sockets and on HTML5 builds it bypasses the websocket code and interacts with the socket directly. This client is the one used in the example project.

## 2. Sec-WebSocket-Protocol and Chrome
Emscripten will create websockets with the Sec-WebSocket-Protocol header set to "binary" during the handshake. Google Chrome expects the response header to include the same Sec-WebSocket-Protocol header. Some websocket examples and the commonly used [Echo Test service](https://www.websocket.org/echo.html) does not respect this and omits the response header. This will cause websocket connections to fail during the handshake phase in Chrome. Firefox does impose the same restriction. I'm not sure about other browsers.

## 3. HTML5 builds and missing bitop module
For the sake of completeness this example has modified the websocket/bit.lua file to use a pure Lua implementation of the bitop library included in LuaJIT as a fallback in HTML5 builds where the bitop library is currently not included. This modification is strictly speaking not really necessary since the websocket frame encode and decode is taken care of by Emscripten and not Lua, but I figured that its better if all code included in the project can be run on all platforms.

# Testing using a Python based echo server
There's a Python based websocket echo server in the example folder. The echo server is built using the [simple-websocket-server](https://github.com/dpallot/simple-websocket-server) library. Start it by running `python websocketserver.py` from a terminal. Connect to it from `localhost:9999`. The library has been modified to return the Sec-WebSocket-Protocol response header, as described above.

# Future improvements
## A separate library project
This example will at some point be moved to its own Defold project, packaged as a library project for simple integration in other Defold projects.

require('websocket.client_sync')
local frame = require'websocket.frame'
local client = require'websocket.client'
local server = require'websocket.server'

return {
  client = client,
  server = server,
  CONTINUATION = frame.CONTINUATION,
  TEXT = frame.TEXT,
  BINARY = frame.BINARY,
  CLOSE = frame.CLOSE,
  PING = frame.PING,
  PONG = frame.PONG
}

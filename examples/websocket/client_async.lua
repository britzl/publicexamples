--- Async websocket client based on standard Lua coroutines. Requires the 
-- lua-websocket library (https://github.com/lipp/lua-websockets)
--
-- Copyright (c) 2012 by Björn Ritzl <bjorn.ritzl@king.com>
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.
--
-- @usage
--
-- 	local wsc = websocket_async()
-- 	wsc:on_message(function(message)
-- 		print(message)
-- 	end)
-- 	wsc:on_connected(function(ok, err)
-- 		wsc:send("Foobar")
-- 	end)
-- 	wsc:connect("ws://echo.websocket.org", "echo")
-- 
-- 	print("Calling step function frequently to update the async websocket")
-- 	while true do
-- 		wsc.step()
-- 		socket.select(nil, nil, 0.5)
-- 	end

local socket = require'socket'
local sync = require'websocket.sync'
local tools = require'websocket.tools'

local new = function(emscripten)
	local self = {}

	self.sock_connect = function(self,host,port)
		assert(coroutine.running(), "You must call the connect function from a coroutine")
		self.sock = socket.tcp()
		self.sock:settimeout(0)
		local success,err = self.sock:connect(host,port)
		if err ~= "timeout" then
			self.sock:close()
			return nil, err
		else
			local sendt = { self.sock }
			while true do
				local receive_ready, send_ready, err = socket.select(nil, sendt, 0)
				if err == "timeout" then
					coroutine.yield()
				elseif err then
					self.sock:close()
					return nil, err
				elseif #send_ready == 1 then
					return
				end
			end
		end
	end

	self.sock_send = function(self, data, i, j)
		assert(coroutine.running(), "You must call the send function from a coroutine")
		local sent = 0
		i = i or 1
		j = j or #data
		while i < j do
			self.sock:settimeout(0)
			local bytes_sent, err = self.sock:send(data, i, j)
			if err == "timeout" then
				coroutine.yield()
			elseif err then
				return nil, err
			else
				coroutine.yield()
			end
			i = i + bytes_sent
			sent = sent + bytes_sent
		end 
		return sent
	end

	self.sock_receive = function(self, pattern, prefix)
		assert(coroutine.running(), "You must call the receive function from a coroutine")
		local data, err
		repeat
			self.sock:settimeout(0)
			data, err = self.sock:receive(pattern, prefix)
			if err == "timeout" then
				coroutine.yield()
			end
		until data or (err and err ~= "timeout")
		return data, err
	end

	self.sock_close = function(self)
		self.sock:shutdown()
		self.sock:close()
	end
	
	self = sync.extend(self)
	
	local coroutines = {}

	local sync_connect = self.connect
	local sync_send = self.send
	local sync_receive = self.receive
	local sync_close = self.close

	local on_connected_fn
	local on_message_fn
	
	
	self.connect = function(...)
		local co = coroutine.create(function(self, ws_url, ws_protocol)
			if emscripten then
  				local protocol, host, port, uri = tools.parse_url(ws_url)
				self.sock_connect(self, host, port)
				self.state = "OPEN"
				if on_connected_fn then on_connected_fn(ok, err) end
			else
				local ok, err =  sync_connect(self,ws_url,ws_protocol)
				if on_connected_fn then on_connected_fn(ok, err) end
			end
		end)
		coroutines[co] = true
		coroutine.resume(co, ...)
	end
	
	self.send = function(...)
		local co = coroutine.create(function(...)
			if emscripten then
				self.sock_send(...)
			else
				local bytes_sent, err = sync_send(...)
			end
		end)
		coroutines[co] = true
		coroutine.resume(co, ...)
	end
	
	self.receive = function(...)
		local co = coroutine.create(function(...)
			if emscripten then
				local data, err = self.sock_receive(...)
				if on_message_fn then on_message_fn(data, err) end
			else
				local data, opcode, was_clean, code, reason = sync_receive(...)
				if on_message_fn then on_message_fn(data, reason) end
			end
		end)
		coroutines[co] = true
		coroutine.resume(co, ...)
	end
	
	self.close = function(...)
		if emscripten then
			self.sock_close(...)
			self.state = "CLOSED"
		else
			sync_close(...)
		end
	end

	
	self.step = function(self)
		for co,_ in pairs(coroutines) do
			if co and coroutine.status(co) == "suspended" then
				coroutine.resume(co)
			end
		end
	end
	
	self.on_message = function(self, fn)
		on_message_fn = fn
		local co = coroutine.create(function()
			while true do
				if self.sock then
					if emscripten then
						-- I haven't figured out how to know the length of the received data
						-- receiving with a pattern of "*a" or "*l" will block indefinitely
						local data, err = self.sock_receive(self, 1)
						if on_message_fn then on_message_fn(data, err) end
					else
						local message, opcode, was_clean, code, reason = sync_receive(self)
						if message then on_message_fn(message) end
					end
				end
				coroutine.yield()
			end
		end)
		coroutines[co] = true
	end
	
	self.on_connected = function(self, fn)
		on_connected_fn = fn
	end
	
	return self
end

return new

local socket = require'socket'
local sync = require'websocket.sync'
local tools = require'websocket.tools'

local new = function()
	local self = {}

	local coroutines = {}
	local on_connected_fn
	
	self.on_message = function(self, fn)
		local co = coroutine.create(function()
			while true do
				--print("in receive")
				if self.sock then
					self.sock:settimeout(0)
					local message, opcode, was_clean, code, reason = self:receive()
					if message then
						fn(message)
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

	self.sock_send = function(self, ...)
		return self.sock:send(...)
	end

	self.sock_receive = function(self,...)
		assert(coroutine.running(), "You must call the receive function from a coroutine")
		local data, err
		repeat
			self.sock:settimeout(0)
			data, err = self.sock:receive(...)
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
	
	
	local sync_connect = self.connect
	self.connect = function(...)
		local co = coroutine.create(function(...)
			local ok, err =  sync_connect(...)
			if on_connected_fn then on_connected_fn(ok, err) end
		end)
		coroutines[co] = true
		coroutine.resume(co, ...)
	end

	
	self.step = function(self)
		for co,_ in pairs(coroutines) do
			if co and coroutine.status(co) == "suspended" then
				coroutine.resume(co)
			end
		end
	end

	
	return self
end

return new

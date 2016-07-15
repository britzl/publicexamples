local socket = require'socket'
local sync = require'websocket.sync'

local new = function()
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
			end
			i = i + bytes_sent
			sent = sent + bytes_sent
		end 
		return sent
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
	
	local coroutines = {}

	local sync_connect = self.connect
	local sync_send = self.send
	local sync_receive = self.receive

	local on_connected_fn
	local on_message_fn
	
	
	self.connect = function(...)
		local co = coroutine.create(function(...)
			local ok, err =  sync_connect(...)
			if on_connected_fn then on_connected_fn(ok, err) end
		end)
		coroutines[co] = true
		coroutine.resume(co, ...)
	end
	
	self.send = function(...)
		local co = coroutine.create(function(...)
			local bytes_sent, err = sync_send(...)
		end)
		coroutines[co] = true
		coroutine.resume(co, ...)
	end
	
	self.receive = function(...)
		local co = coroutine.create(function(...)
			local data, err = sync_receive(...)
			if on_message_fn then on_message_fn(data, err) end
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
	
	self.on_message = function(self, fn)
		on_message_fn = fn
		local co = coroutine.create(function()
			while true do
				if self.sock then
					self.sock:settimeout(0)
					local message, opcode, was_clean, code, reason = sync_receive(self)
					if message then
						on_message_fn(message)
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

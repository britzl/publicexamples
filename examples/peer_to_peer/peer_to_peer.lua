local socket = require("builtins.scripts.socket")

local M = {}

local STATE_DISCONNECTED = "STATE_DISCONNECTED"
local STATE_BROADCASTING = "STATE_BROADCASTING"
local STATE_LISTENING = "STATE_LISTENING"

local function create_udp_broadcast(port)
	local udp_broadcast, err = socket.udp()
	if not udp_broadcast then
		return nil, err
	end
	
	local ok, err = udp_broadcast:settimeout(0)
	if not ok then
		return nil, err
	end
	
	local ok, err = udp_broadcast:setsockname("*", port)
	if not ok then
		return nil, err
	end
	
	local ok, err = udp_broadcast:setoption("broadcast", true)
	if not ok then
		return nil, err
	end

	local ok, err = udp_broadcast:setpeername("255.255.255.255", port)
	if not ok then
		return nil, err
	end
	
	return udp_broadcast
end


local function create_udp_listen(port)
	local udp_listen, err = socket.udp()
	if not udp_listen then
		return nil, err
	end
	
	local ok, err = udp_listen:settimeout(0)
	if not ok then
		return nil, err
	end

	local ok, err = udp_listen:setpeername("255.255.255.255", port)
	if not ok then
		return nil, err
	end
	
	return udp_listen
end


function M.create()
	print("create")
	local instance = {}
	
	local state = STATE_DISCONNECTED

	local listen_co
	local broadcast_co
	
	function instance.broadcast(port)
		local udp_broadcast, err = create_udp_broadcast(port)
		if not udp_broadcast then
			return false, err
		end
		
		state = STATE_BROADCASTING
		broadcast_co = coroutine.create(function()
			while state == STATE_BROADCASTING do
				--print("broadcasting")
				local ok, err = udp_broadcast:send('this is a test')
				if err then
					state = STATE_DISCONNECTED
				else
					coroutine.yield()
				end
			end
			udp_broadcast:close()
			broadcast_co = nil
		end)
		return coroutine.resume(broadcast_co)
	end
	
	function instance.listen(port)
		local udp_listen, err = create_udp_listen(port)
		if not udp_listen then
			return false, err
		end
		
		state = STATE_LISTENING
		listen_co = coroutine.create(function()
			while state == STATE_LISTENING do
				--print("listening")
				local data, err = udp_listen:receive()
				print(data, err)
				if data then
					print(data)
				end
				coroutine.yield()
			end
			listen_co = nil
		end)
		return coroutine.resume(listen_co)
	end
	
	function instance.update()
		if broadcast_co then
			if coroutine.status(broadcast_co) == "suspended" then
				coroutine.resume(broadcast_co)
			end
		elseif listen_co then
			if coroutine.status(listen_co) == "suspended" then
				coroutine.resume(listen_co)
			end
		end
	end

	return instance
end


return M
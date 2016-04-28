local socket = require("builtins.scripts.socket")

local M = {}

local STATE_DISCONNECTED = "STATE_DISCONNECTED"
local STATE_BROADCASTING = "STATE_BROADCASTING"
local STATE_LISTENING = "STATE_LISTENING"

local function get_ip()
	for _,network_card in pairs(sys.get_ifaddrs()) do
		if network_card.up and network_card.address then
			return network_card.address
		end
	end
	return nil
end


function M.create()
	print("create")
	local instance = {}
	
	local state = STATE_DISCONNECTED

	local multicast_ip = "226.192.1.1"
	local broadcast_port = 8100

	local listen_co
	local broadcast_co
	
	function instance.broadcast(message)
		assert(message, "You must provide a message to broadcast")
		local broadcaster
		local ok, err = pcall(function()
			broadcaster = socket.udp()
			broadcaster:settimeout(0)
		end)
		if not broadcaster then
			return false, err
		end
		
		print("Broadcasting " .. message) 
		state = STATE_BROADCASTING
		broadcast_co = coroutine.create(function()
			while state == STATE_BROADCASTING do
				local ok, err = pcall(function()
					broadcaster:sendto(message, multicast_ip, broadcast_port)
					broadcaster:setoption("broadcast", true)
					broadcaster:sendto(message, "255.255.255.255", broadcast_port)
					broadcaster:setoption("broadcast", false)
				end)
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
	
	function instance.listen(message)
		assert(message, "You must provide a message to listen for")
		local listener
		local ok, err = pcall(function()
			listener = socket.udp()
			listener:setsockname("0.0.0.0", broadcast_port)
		
			-- try multicast
			if listener:getsockname() then
				listener:setoption("ip-add-membership", { multiaddr = multicast_ip, interface = get_ip() } )
			-- fallback to broadcast
			else
				listener:close()
				listener = socket.udp()
				listener:setsockname(get_ip(), broadcast_port)
			end
			
			listener:settimeout(0)
		end)
		if not listener then
			return false, err
		end
		
		print("Listening for " .. message)
		state = STATE_LISTENING
		listen_co = coroutine.create(function()
			while state == STATE_LISTENING do
				local data, ip, port = listener:receivefrom()
				if data and data == message then
					print("Found server on " .. ip .. ":" .. port)
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
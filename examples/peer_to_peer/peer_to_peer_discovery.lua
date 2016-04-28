--- Module to perform peer-to-peer discovery
-- The module can either broadcast it's existence or listen for others
-- Inspired by code from https://coronalabs.com/blog/2014/09/23/tutorial-local-multiplayer-with-udptcp/

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

--- Create a peer to peer discovery instance
function M.create(multicast_ip, port)
	local instance = {}
	
	local state = STATE_DISCONNECTED

	multicast_ip = multicast_ip or "226.192.1.1"
	port = port or 8100

	local listen_co
	local broadcast_co
	
	--- Start broadcasting a message for others to discover
	-- @param message
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
		
		print("Broadcasting " .. message .. " from " .. get_ip()) 
		state = STATE_BROADCASTING
		broadcast_co = coroutine.create(function()
			while state == STATE_BROADCASTING do
				local ok, err = pcall(function()
					broadcaster:sendto(message, multicast_ip, port)
					broadcaster:setoption("broadcast", true)
					broadcaster:sendto(message, "255.255.255.255", port)
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
	
	--- Start listening for a broadcasting server
	-- @param message The message to listen for
	-- @param callback Function to call when a broadcasting server has been found. The function
	-- must accept the broadcasting server's IP and port as arguments. 
	function instance.listen(message, callback)
		assert(message, "You must provide a message to listen for")
		local listener
		local ok, err = pcall(function()
			listener = socket.udp()
			listener:setsockname("0.0.0.0", port)
		
			-- try multicast
			if listener:getsockname() then
				listener:setoption("ip-add-membership", { multiaddr = multicast_ip, interface = get_ip() } )
			-- fallback to broadcast
			else
				listener:close()
				listener = socket.udp()
				listener:setsockname(get_ip(), port)
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
				local data, server_ip, server_port = listener:receivefrom()
				if data and data == message then
					callback(server_ip, server_port)
					state = STATE_DISCONNECTED
					break
				end
				coroutine.yield()
			end
			listen_co = nil
		end)
		return coroutine.resume(listen_co)
	end
	
	--- Stop broadcasting or listening
	function instance.stop()
		state = STATE_DISCONNECTED
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
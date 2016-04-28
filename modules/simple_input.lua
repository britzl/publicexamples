local M = {}

local registered_nodes = {}

local function ensure_node(node_or_node_id)
	return type(node_or_node_id) == "string" and gui.get_node(node_or_node_id) or node_or_node_id 
end

--- Convenience function to acquire input focus
function M.acquire()
	msg.post(".", "acquire_input_focus")
end

--- Convenience function to release input focus
function M.release()
	msg.post(".", "release_input_focus")
end

--- Register a node and a callback to invoke when the node
-- receives input
function M.register(node_or_string, callback)
	assert(node_or_string, "You must provide a node")
	assert(callback, "You must provide a callback")
	local node = ensure_node(node_or_string)
	local node_id = gui.get_id(node)
	registered_nodes[hash_to_hex(node_id)] = { url = msg.url(), callback = callback, node_id = node_id }
end

--- Unregister a previously registered node or all nodes
-- registered from the calling script
-- @param node_or_string
function M.unregister(node_or_string)
	if not node_or_string then
		local url = msg.url()
		for k,registered_node in pairs(registered_nodes) do
			if registered_node.url == url then
				registered_nodes[k] = nil
			end
		end
	else
		local node = ensure_node(node_or_string)
		local node_id = gui.get_id(node)
		registered_node[hash_to_hex(node_id)] = nil
	end
end

local function shake(node)
	gui.cancel_animation(node, "scale.x")
	gui.cancel_animation(node, "scale.y")
	gui.set_scale(node, vmath.vector3(1.1))
	gui.animate(node, "scale.x", 1.0, gui.EASING_OUTELASTIC, 0.8)
	gui.animate(node, "scale.y", 1.0, gui.EASING_OUTELASTIC, 0.8, 0.05, function()
		gui.set_scale(node, vmath.vector3(1.0))
	end)
end

local function is_enabled(node)
	local enabled = gui.is_enabled(node)
	local parent = gui.get_parent(node)
	if not enabled or not parent then
		return enabled
	else
		return is_enabled(parent)
	end
end

--- Forward on_input calls to this function to detect input
-- for registered nodes
-- @param action_id,
-- @param action
-- @return true if input a registerd node received input
function M.on_input(action_id, action)
	if action.released then
		local url = msg.url()
		for _,registered_node in pairs(registered_nodes) do
			if registered_node.url == url then
				local node = gui.get_node(registered_node.node_id)
				if is_enabled(node) and gui.pick_node(node, action.x, action.y) then
					shake(node)
					registered_node.callback()
					return true
				end
			end
		end
	end
	return false
end

return M
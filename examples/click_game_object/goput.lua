--- Module to simplify input handling of game objects with sprites

local M = {}

local sprites = {}


--- Add a sprite that should be able to receive input
-- @param sprite_url URL to the sprite component
-- @param sprite_offset If the sprite is offset from 0,0 this value needs to
-- be provided here since there is no way to read sprite position at run-time
-- @param on_input_callback The function to call when the sprite receives input. The
-- function must accept three values:
--   url - URL of the game object that received input
--   action_id - action id from on_input
--   action - action table from on_input 
function M.add(sprite_url, sprite_offset, on_input_callback)
	assert(sprite_url)
	assert(on_input_callback)
	sprite_offset = sprite_offset or vmath.vector3()
	sprite_url = type(sprite_url) == "string" and msg.url(sprite_url) or sprite_url
	sprites[tostring(sprite_url)] = {
		sprite_url = sprite_url,
		go_url = msg.url(sprite_url.socket, sprite_url.path, nil),
		offset = sprite_offset,
		callback = on_input_callback, size = go.get(sprite_url, "size") }
end

--- Remove a previously added sprite
-- @param sprite_url
function M.remove(sprite_url)
	assert(sprite_url)
	sprite_url = type(sprite_url) == "string" and msg.url(sprite_url) or sprite_url 
	sprites[tostring(sprite_url)] = nil
end

--- Forward input from a script that has acquire input focus
-- @param action_id Action id as received from on_input
-- @param action Action table as received from on_input
-- @return Will return value returned by the callback function for
-- tge game object that received input or false if no game object
-- received input 
function M.on_input(action_id, action)
	for _,sprite_data in pairs(sprites) do
		local go_scale = go.get_scale_vector(sprite_data.go_url)
		local sprite_scale = go.get(sprite_data.sprite_url, "scale")
		local size = sprite_data.size
		local pos = go.get_position(sprite_data.go_url)
		pos.x = pos.x + sprite_data.offset.x * go_scale.x
		pos.y = pos.y + sprite_data.offset.y * go_scale.y
		
		local scaled_size = vmath.vector3(size.x * go_scale.x * sprite_scale.x, size.y * go_scale.y * sprite_scale.y, 0)
		
		if action.x >= pos.x - scaled_size.x / 2 and action.x <= pos.x + scaled_size.x / 2 and action.y >= pos.y - scaled_size.y / 2 and action.y <= pos.y + scaled_size.y / 2 then
			return sprite_data.callback(sprite_data.go_url, action_id, action)
		end
	end
	return false
end

return M
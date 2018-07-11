local M = {}

-- create a simple button handler
-- @param node The node representing the button
-- @param pressed_animation
-- @param released_animation
-- @param callback Function to call when button is clicked
-- @return Button instance
function M.create(node, pressed_animation, released_animation, callback)
	local button = {
		pressed = false
	}

	-- make sure it's in the released
	gui.play_flipbook(node, released_animation)

	-- define the input handler function
	function button.on_input(action_id, action)
		-- mouse/finger over the button?
		local over = gui.pick_node(node, action.x, action.y)
		-- over button and mouse/finger pressed?
		if over and action.pressed then
			button.pressed = true
			gui.play_flipbook(node, pressed_animation)
		-- mouse/finger released and button pressed?
		elseif action.released and button.pressed then
			button.pressed = false
			gui.play_flipbook(node, released_animation)
			-- only treat this as a click if finger/mouse is over button when releasing
			if over then
				callback(button)
			end
		end
	end

	return button
end


return M
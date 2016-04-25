local M = {}

M.zoom = true

function M.action_to_position(action)
	if M.zoom then
		return vmath.vector3(action.screen_x * (M.zoom_factor or 1), action.screen_y * (M.zoom_factor or 1), 0)
	else
		return vmath.vector3(action.screen_x, action.screen_y, 0)
	end
end

return M
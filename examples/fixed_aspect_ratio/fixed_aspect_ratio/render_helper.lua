local M = {}

function M.action_to_position(action)
	return vmath.vector3((M.xoffset or 0) + action.screen_x / (M.zoom_factor or 1), (M.yoffset or 0) + action.screen_y / (M.zoom_factor or 1), 0)
end

return M
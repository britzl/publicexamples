local M = {}

local values = {}

function M.add(key, value)
	assert(key, "You must provide a key")
	assert(value, "You must provide a value")
	values[key] = value
end

function M.remove(key)
	assert(key, "You must provide a key")
	values[key] = nil
end

function M.get(key)
	assert(key, "You must provide a key")
	return values[key]
end

return M

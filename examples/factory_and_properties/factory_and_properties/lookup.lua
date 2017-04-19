local M = {}

local values = {}

function M.add(key, value)
	assert(key, "You must provide a key")
	assert(value, "You must provide a value")
	key = type(key) == "hash" and hash_to_hex(key) or key -- keys can't be of type hash or else table lookups will fail in release builds
	values[key] = value
end

function M.remove(key)
	assert(key, "You must provide a key")
	key = type(key) == "hash" and hash_to_hex(key) or key
	values[key] = nil
end

function M.get(key)
	assert(key, "You must provide a key")
	key = type(key) == "hash" and hash_to_hex(key) or key
	return values[key]
end

return M
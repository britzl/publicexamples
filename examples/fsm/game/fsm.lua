local M = {}

local hash_to_hex_lookup = {}

local function lookup_hash_to_hex(h)
	if hash_to_hex_lookup[h] then
		return hash_to_hex_lookup[h]
	else
		local hex = hash_to_hex(h)
		hash_to_hex_lookup[h] = hex
		return hex
	end
end

local transition_lookup = { value = "", children = {} }

local function get_transition_id(...)
	local lookup = transition_lookup
	local count = select("#", ...)
	for i = 1, count do
		local h = select(i, ...)
		local hex = lookup_hash_to_hex(h)
		if lookup.children[hex] then
			lookup = lookup.children[hex]
		else
			lookup.children[hex] = {
				value = lookup.value .. hex,
				children = {}
			}
			lookup = lookup.children[hex]
		end
	end
	return lookup.value
end


function M.create(name)
	
	local fsm = { name = name }
	
	local current_state = nil
	
	function fsm.start(state)
		current_state = state
		current_state.enter()
	end
	
	function fsm.update(self, dt)
		current_state.update(self, dt)
	end
	
	function fsm.transition(...)
		assert(current_state)
		local next_state = current_state.transitions[get_transition_id(...)]
		if not next_state then
			return false, "Illegal transition for state"
		end
		current_state.exit()
		current_state = next_state
		next_state.enter()
		return true
	end
	
	local function create_state(id)
		local state = {
			transitions = {},
			id = id,
		}

		local on_enter = nil
		local on_exit = nil
		local on_update = nil
		
		function state.on_enter(fn)
			on_enter = fn
			return state
		end
		
		function state.on_exit(fn)
			on_exit = fn
			return state
		end
		
		function state.on_update(fn)
			on_update = fn
			return state
		end
		
		function state.on_transition(next_state, ...)
			assert(next_state, "You must provide a next state ")
			transition_id = get_transition_id(...)
			state.transitions[transition_id] = next_state
			return state
		end
				
		function state.exit()
			if on_exit then
				on_exit()
			end
		end
		
		function state.enter()
			if on_enter then
				on_enter()
			end
		end
		
		function state.update(self, dt)
			if on_update then
				on_update(self, dt)
			end
		end
		
		
		return state
	end
	
	
	
	local mt = {
		__index = function(t, k)
			if type(k) == "string" then
				k = hash(k)
				if not rawget(fsm, k) then
					local state = create_state(k)
					rawset(fsm, k, state)
				end
			end
			return rawget(fsm, k)
		end,
		__newindex = function(t, k, v)
			print("NEWINDEX", t, k, v)
		end,
	}
	
	setmetatable(fsm, mt)
	
	
	return fsm
end



return M
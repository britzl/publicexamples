local translations = require "examples.localization.translations"

local M = {
	default_language = "en",
	current_language = sys.get_sys_info().device_language or sys.get_sys_info().language
}

--- Change current language
-- @param language
function M.change_language(language)
	M.current_language = language
end


--- Get translation for a specific key, optionally formatting it with
-- additional values
-- @param key The key containing the text to translate
-- @return The translated text
function M.translate(key, ...)
	local t = translations[M.current_language] or translations[M.default_language]
	if not t or not t[key] then
		return key
	else
		if select("#", ...) > 0 then
			return t[key]:format(...)
		else
			return t[key]
		end
	end
end

-- this will make it possible to call the module table as a function and invoke M.translate()
return setmetatable(M, {
	__call = function(self, key, ...)
		return M.translate(key, ...)
	end
})
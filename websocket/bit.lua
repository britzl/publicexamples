local has_bit32,bit = pcall(require,'bit32')
if has_bit32 then
  -- lua 5.2 / bit32 library
  bit.rol = bit.lrotate
  bit.ror = bit.rrotate
  return bit
else
  -- luajit / lua 5.1 + luabitop
  if not _G.bit then
    print("Warning! No bit op support. Using pure Lua bit implementation.")
    local numberlua = require "lmod.bit.numberlua"
    _G.bit = numberlua.bit
  end
  return _G.bit
end

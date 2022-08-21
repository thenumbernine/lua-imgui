--[[
TODO move this into ffi.imgui because I'm using it so much
same as the non-C part of my lua-ffi-bindings, same as hydro-cl/hydro/toolkit
--]]
local ffi = require 'ffi'
local ig = require 'ffi.cimgui'
local table = require 'ext.table'

-- ig interface but with lua tables
local iglua = {}

local ImVec2 = ffi.metatype('ImVec2', {})
iglua.ImVec2 = ImVec2
local ImVec4 = ffi.metatype('ImVec4', {})
iglua.ImVec4 = ImVec4 

local tmpbool = ffi.new'bool[1]'
local tmpfloat = ffi.new'float[1]'



-- HERE IS MY ATTEMPT AT C++ DEFAULT PARAMS
-- BUT MIND YOU MY API IS A FEW VERSIONS OLD, SO IT'S PROBABLY A MIX OF VERSIONS OF DEFAULT PARAMETERS



-- I would use the ffi comparison, but it is only checks wrt const-ness
-- it doesn't equate pointers and arrays
local function isptr(x, ptrPattern)
	if type(x) ~= 'cdata' then return false end
	local ctype = tostring(ffi.typeof(x))
	-- the original ctype
	return ctype:match('^ctype<'..ptrPattern..'%s*%*>$')
	-- maybe const
		or ctype:match('^ctype<const%s+'..ptrPattern..'%s*%*>$')
	-- maybe array
		or ctype:match('^ctype<'..ptrPattern..'%s*%[.*%]>$')
	-- maybe const array
		or ctype:match('^ctype<const%s+'..ptrPattern..'%s*%[.*%]>$')
end

function iglua.igBegin(...)
	local n = select('#', ...)
	local name, p_open, flags = ...
	if n < 2 then p_open = nil end
	if n < 3 then flags = 0 end
	return ig.igBegin(name, p_open, flags)
end
function iglua.igBeginChild(...)
	local n = select('#', ...)
	local arg1, size, border, extra_flags = ...
	if n < 2 then size = ImVec2(0,0) end
	if n < 3 then border = false end
	if n < 4 then extra_flags = 0 end
	if type(arg1) == 'number'
	or (type(arg1) == 'cdata' and ffi.istype('ImGuiID', arg1))
	then
		return ig.igBeginChild_ID(arg1, size, border, extra_flags)
	else	-- string
		return ig.igBeginChild_Str(arg1, size, border, extra_flags)
	end
end
function iglua.igBeginMenu(...)
	local n = select('#', ...)
	local label, enabled = ...
	if n < 2 then enabled = true end
	return ig.igBeginMenu(label, enabled)
end
function iglua.igBeginPopupModal(...)
	local n = select('#', ...)
	local name, p_open, extra_flags = ...
	if n < 2 then p_open = nil end
	if n < 3 then extra_flags = 0 end
	return ig.igBeginPopupModal(name, p_open, extra_flags)
end
function iglua.igButton(...)
	local n = select('#', ...)
	local label, size = ...
	if n < 2 then size = ImVec2(0,0) end
	return ig.igButton(label, size)
end
function iglua.igCollapsingHeader(...)
	local n = select('#', ...)
	-- if the 2nd arg is a pointer then use the 2nd prototype
	if isptr(select(2, ...), 'bool') then
		local label, p_open, flags = ...
		if n < 3 then flags = 0 end
		return ig.igCollapsingHeader_BoolPtr(label, p_open, flags)
	else
		local label, flags = ...
		if n < 2 then flags = 0 end
		return ig.igCollapsingHeader_TreeNodeFlags(label, flags)
	end
end
function iglua.igCombo(...)
	local n = select('#', ...)
	local arg3 = select(3, ...)
	local type3 = type(arg3)
	if isptr(select(3, ...), 'char%s*%*') then
		local label, current_item, items, item_count, height_in_items = ...
		if n < 5 then height_in_items = -1 end
		return ig.igCombo_Str_arr(label, current_item, items, item_count, height_in_items)
	elseif type3 == 'function' or ctype3 == 'ctype<bool (*)()>'  then	-- why doesn't ffi.typeof(ffi.cast) for callbacks show any arguments?
		local label, current_item, items_getter, data, items_count, height_in_items = ...
		if n < 6 then height_in_items = -1 end
		return ig.igCombo_FnBoolPtr(label, current_item, items_getter, data, items_count, height_in_items)
	-- lua compat:
	elseif type3 == 'table' then
		local label, current_item, item_table, height_in_items = ...
		if n < 4 then height_in_items = -1 end
		local items_separated_by_zeros = table.concat(item_table, '\0')..'\0'
		return ig.igCombo_Str(label, current_item, items_separated_by_zeros, height_in_items)
	else
		local label, current_item, items_separated_by_zeros, height_in_items = ...
		if n < 4 then height_in_items = -1 end
		return ig.igCombo_Str(label, current_item, items_separated_by_zeros, height_in_items)
	end
end
function iglua.igColorButton(...)
	local n = select('#', ...)
	local col, small_height, outline_border = ...
	if type(col) == 'table' then col = ImVec4(table.unpack(col,1,4)) end
	if n < 2 then small_height = false end
	if n < 3 then outline_border = true end
	return ig.igColorButton(col, small_height, outline_border)
end
function iglua.igInputFloat(...)
	local n = select('#', ...)
	local label, v, step, step_fast, format, flags = ...
	if n < 3 then step = 0 end
	if n < 4 then step_fast = 0 end
	if n < 5 then format = '%3f' end
	if n < 6 then flags = 0 end
	return ig.igInputFloat(label, v, step, step_fast, format, flags)
end
function iglua.igInputFloat2(...)
	local n = select('#', ...)
	local label, v, format, flags = ...
	if n < 3 then format = '%3f' end
	if n < 4 then flags = 0 end
	return ig.igInputFloat2(label, v, format, flags)
end
function iglua.igInputFloat3(...)
	local n = select('#', ...)
	local label, v, format, flags = ...
	if n < 3 then format = '%3f' end
	if n < 4 then flags = 0 end
	return ig.igInputFloat3(label, v, format, flags)
end
function iglua.igInputFloat4(...)
	local n = select('#', ...)
	local label, v, format, flags = ...
	if n < 3 then format = '%3f' end
	if n < 4 then flags = 0 end
	return ig.igInputFloat4(label, v, format, flags)
end
function iglua.igInputInt(...)
	local n = select('#', ...)
	local label, v, step, step_fast, extra_flags = ...
	if n < 3 then step = 1 end
	if n < 4 then step_fast = 100 end
	if n < 5 then extra_flags = 0 end
	return ig.igInputInt(label, v, step, step_fast, extra_flags)
end
function iglua.igInputInt2(...)
	local n = select('#', ...)
	local label, v, extra_flags = ...
	if n < 3 then extra_flags = 0 end
	return ig.igInputInt2(label, v, extra_flags)
end
function iglua.igInputInt3(...)
	local n = select('#', ...)
	local label, v, extra_flags = ...
	if n < 3 then extra_flags = 0 end
	return ig.igInputInt3(label, v, extra_flags)
end
function iglua.igInputInt4(...)
	local n = select('#', ...)
	local label, v, extra_flags = ...
	if n < 3 then extra_flags = 0 end
	return ig.igInputInt4(label, v, extra_flags)
end
iglua.igGetCursorScreenPos = (function()
	local result = ffi.new('struct ImVec2[1]')
	return function()
		ig.igGetCursorScreenPos(result)
		return result[0]
	end
end)()
iglua.igGetMousePos = (function()
	local result = ffi.new('struct ImVec2[1]')
	return function()
		ig.igGetMousePos(result)
		return result[0]
	end
end)()
iglua.igGetWindowSize = (function()
	local result = ffi.new('struct ImVec2[1]')
	return function()
		ig.igGetWindowSize(result)
		return result[0]
	end
end)()
function iglua.igImage(...)
	local n = select('#', ...)
	local user_texture_id, size, uv0, uv1, tint_col, border_col = ...
	if n < 3 then uv0 = ImVec2(0,0) end
	if n < 4 then uv1 = ImVec2(1,1) end
	if n < 5 then tint_col = ImVec4(1,1,1,1) end
	if n < 6 then border_col = ImVec4(0,0,0,0) end
	return ig.igImage(user_texture_id, size, uv0, uv1, tint_col, border_col)
end
function iglua.igImageButton(...)
	local n = select('#', ...)
	local user_texture_id, size, uv0, uv1, frame_padding, bg_col, tint_col = ...
	if n < 3 then uv0 = ImVec2(0,0) end
	if n < 4 then uv1 = ImVec2(1,1) end
	if n < 5 then frame_padding = -1 end
	if n < 6 then bg_col = ImVec4(0,0,0,0) end
	if n < 7 then tint_col = ImVec4(1,1,1,1) end
	return ig.igImageButton(user_texture_id, size, uv0, uv1, frame_padding, bg_col, tint_col)
end
function iglua.igInputText(...)
	local n = select('#', ...)
	local label, buf, buf_size, flags, callback, user_data = ...
	if n < 4 then flags = 0 end
	if n < 5 then callback = nil end
	if n < 6 then user_data = nil end
	return ig.igInputText(label, buf, buf_size, flags, callback, user_data)
end
function iglua.igInputTextMultiline(...)
	local n = select('#', ...)
	local label, buf, buf_size, size, flags, callback, user_data = ...
	if n < 4 then size = ImVec2(0,0) end
	if n < 5 then flags = 0 end
	if n < 6 then callback = nil end
	if n < 7 then user_data = nil end
	return ig.igInputTextMultiline(label, buf, buf_size, size, flags, callback, user_data)
end
function iglua.igMenuItem(...)
	local n = select('#', ...)
	local label, shortcut, arg2, enabled = ...
	if n < 2 then shortcut = nil end
	if n < 3 then arg2 = false end
	if n < 4 then enabled = true end
	if isptr(arg2, 'bool') then
		return ig.igMenuItem_BoolPtr(label, shortcut, arg2, enabled)
	else
		return ig.igMenuItem_Bool(label, shortcut, arg2, enabled)
	end
end
function iglua.igSameLine(...)
	local n = select('#', ...)
	local pos_x, spacing_w = ...
	if n < 1 then pos_x = 0 end
	if n < 2 then spacing_w = -1 end
	return ig.igSameLine(pos_x, spacing_w)
end
function iglua.igSelectable(...)
	local n = select('#', ...)
	local label, arg2, flags, size = ...
	if n < 2 then arg2 = false end
	if n < 3 then flags = 0 end
	if n < 4 then size = ImVec2(0,0) end
	if isptr(arg2, 'bool') then
		return ig.igSelectable_BoolPtr(label, arg2, flags, size)
	else
		return ig.igSelectable_Bool(label, arg2, flags, size)
	end
end
function iglua.igSetScrollHere(...)
	local n = select('#', ...)
	local center_y_ratio = ...
	if n < 1 then center_y_ratio = .5 end
	return ig.igSetScrollHereY(center_y_ratio)
end
function iglua.igSetScrollFromPosY(...)
	local n = select('#', ...)
	local pos_y, center_y_ratio = ...
	if n < 2 then center_y_ratio = .5 end
	return ig.igSetScrollFromPosY(pos_y, center_y_ratio)
end
function iglua.igSliderFloat(...)
	local n = select('#', ...)
	local label, v, v_min, v_max, display_format, power = ...
	if n < 4 then display_format = '%.3f' end
	if n < 5 then power = 1 end
	return ig.igSliderFloat(label, v, v_min, v_max, display_format, power)
end
function iglua.igSliderFloat2(...)
	local n = select('#', ...)
	local label, v, v_min, v_max, display_format, power = ...
	if n < 4 then display_format = '%.3f' end
	if n < 5 then power = 1 end
	return ig.igSliderFloat2(label, v, v_min, v_max, display_format, power)
end
function iglua.igSliderFloat3(...)
	local n = select('#', ...)
	local label, v, v_min, v_max, display_format, power = ...
	if n < 4 then display_format = '%.3f' end
	if n < 5 then power = 1 end
	return ig.igSliderFloat3(label, v, v_min, v_max, display_format, power)
end
function iglua.igSliderFloat4(...)
	local n = select('#', ...)
	local label, v, v_min, v_max, display_format, power = ...
	if n < 4 then display_format = '%.3f' end
	if n < 5 then power = 1 end
	return ig.igSliderFloat4(label, v, v_min, v_max, display_format, power)
end
function iglua.igSliderInt(...)
	local n = select('#', ...)
	local label, v, v_min, v_max, display_format, flags = ...
	if n < 5 then display_format = '%.0f' end
	if n < 6 then flags = 0 end
	return ig.igSliderInt(label, v, v_min, v_max, display_format, flags)
end
function iglua.igSliderInt2(...)
	local n = select('#', ...)
	local label, v, v_min, v_max, display_format, flags = ...
	if n < 5 then display_format = '%.0f' end
	if n < 6 then flags = 0 end
	return ig.igSliderInt2(label, v, v_min, v_max, display_format, flags)
end
function iglua.igSliderInt3(...)
	local n = select('#', ...)
	local label, v, v_min, v_max, display_format, flags = ...
	if n < 5 then display_format = '%.0f' end
	if n < 6 then flags = 0 end
	return ig.igSliderInt3(label, v, v_min, v_max, display_format, flags)
end
function iglua.igSliderInt4(...)
	local n = select('#', ...)
	local label, v, v_min, v_max, display_format, flags = ...
	if n < 5 then display_format = '%.0f' end
	if n < 6 then flags = 0 end
	return ig.igSliderInt4(label, v, v_min, v_max, display_format, flags)
end



-- HERE IS THE LUA-WRAPPED TYPES
-- I'M GOING TO SKIP ON THE 'ig' PREFIX FOR THESE
-- MAYBE I SHOULD DENOTE THEM SOME OTHER WAY



function iglua.Begin(title, t, k, ...)
	local flagarg
	if t then
		flagarg = tmpbool
		tmpbool[0] = t[k]
	end
	local result = table.pack(ig.igBegin(title, flagarg, ...))
	if t then
		t[k] = not not tmpbool[0]
	end
	return result:unpack()
end

function iglua.SliderFloat(title, t, k, ...)
	tmpfloat[0] = t[k]
	local result = table.pack(ig.igSliderFloat(title, tmpfloat, ...))
	t[k] = tonumber(tmpfloat[0])
	return result:unpack()
end

return setmetatable(iglua, {
	__index = ig,
})

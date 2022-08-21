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
-- API STANDARD, IF the prefix is 'luatable' THEN IT IS A TABLE-BASED NAME
-- API STANDARD, IF the prefix is 'tooltip' THEN IT HAS AN AUTO TOOLTIP (in place of a title) 
-- API STANDARD, IF the prefix is 'luatableTooltip' THEN IT IS BOTH 



function iglua.hoverTooltip(name)
	if ig.igIsItemHovered(ig.ImGuiHoveredFlags_None) then
		ig.igBeginTooltip()
		ig.igText(name)
		ig.igEndTooltip()
	end
end


local function makeWrapTooltip(f)
	assert(f, "expected function")
	-- TODO maybe, assert the first is a ptr, and if not allowNull then assert the ptr is not null
	return function(name, ...)
		--assert(ptr, "forgot to pass a ptr for "..name)
		ig.igPushID_Str(name)
		local result = f('', ...)
		iglua.hoverTooltip(name)
		ig.igPopID()
		return result
	end
end

-- if you want tooltip wrappers for raw C data calls (tho admittadly I don't use this so often)
iglua.tooltipSlider = makeWrapTooltip(iglua.igSliderFloat)
iglua.tooltipCombo = makeWrapTooltip(iglua.igCombo)
iglua.tooltipInputFloat = makeWrapTooltip(iglua.igInputFloat)
iglua.tooltipInputInt = makeWrapTooltip(iglua.igInputInt)
iglua.tooltipInputText = makeWrapTooltip(iglua.igInputText)
iglua.tooltipButton = makeWrapTooltip(iglua.igButton)
iglua.tooltipCheckbox = makeWrapTooltip(ig.igCheckbox)
iglua.tooltipRadioButton = makeWrapTooltip(ig.igRadioButton_IntPtr)	-- TODO instead of _IntPtr, replace with iglua.igRadioButton and do type detect

local function tooltipLabel(label, str)
	ig.igPushID_Str(label)
	ig.igText(str)
	iglua.hoverTooltip(label)
	ig.igPopID()
end

local ident = function(...) return ... end
--[[
args:
	ctype = ctype
	func = callback function
	allowNull = set to 'true' to have a nil table imply passing null into the callback
	castto = function for casting to the ctype
	castfrom = function for casting from the ctype
--]]
local function makeTableAccess(args)
	local ctype = assert(args.ctype, "expected ctype")
	local func = assert(args.func, "expected func")
	local allowNull = args.allowNull
	local castto = args.castto or ident
	local castfrom = args.castfrom or ident
	local ptr = ffi.new(ctype..'[1]')
	return function(title, t, k, ...)
		if allowNull then
			local arg
			if t then
				if t[k] == nil then
					error("failed to find value "..k.." in table "..tostring(t))
				end
				ptr[0] = castto(t[k])
				arg = ptr
			end
			local result = table.pack(func(title, arg, ...))
			if arg then
				t[k] = castfrom(ptr[0])
			end
			return result:unpack()
		else
			if t == nil then
				error("expected table")
			end
			if t[k] == nil then
				error("failed to find value "..k.." in table "..tostring(t))
			end
			ptr[0] = castto(t[k])
			local result = table.pack(func(title, ptr, ...))
			t[k] = castfrom(ptr[0])
			return result:unpack()
		end
	end
end

-- this is table wrap only, no tooltip
iglua.luatableBegin = makeTableAccess{
	ctype = 'bool',
	func = iglua.igBegin,
	allowNull = true,
}

iglua.luatableCheckbox = makeTableAccess{
	ctype = 'bool',
	func = ig.igCheckbox,
	castto = function(x) return not not x end,
}

iglua.luatableSliderFloat = makeTableAccess{
	ctype = 'float',
	func = iglua.igSliderFloat,
}

iglua.luatableSliderInt = makeTableAccess{
	ctype = 'int',
	func = iglua.igSliderInt,
}

iglua.luatableInputFloat = makeTableAccess{
	ctype = 'float',
	func = iglua.igInputFloat,
	castto = tonumber,
}

iglua.luatableInputInt = makeTableAccess{
	ctype = 'int',
	func = iglua.igInputInt,
	castto = tonumber,
}

iglua.luatableRadioButton = makeTableAccess{
	ctype = 'int',
	func = ig.igRadioButton_IntPtr,	-- TODO how about a wrapper above for type-determination?
}

-- this is atypical because I'm 1-offsetting the indexes
do
	local int = ffi.new'int[1]'
	function iglua.luatableCombo(title, t, k, ...)
		assert(t[k])
		assert(type(t[k]) == 'number')
		int[0] = t[k]-1
		if iglua.igCombo(title, int, ...) then
			t[k] = int[0]+1
			return true
		end
	end
end

-- this one is atypical because the ptr is in the 3rd arg instead of the 2nd
do
	local bool = ffi.new'bool[1]'
	function iglua.luatableMenuItem(label, shortcut, t, k, ...)
		assert(t ~= nil)
		assert(t[k] ~= nil)
		bool[0] = t[k]
		local result = table.pack(iglua.igMenuItem(label, shortcut, bool, ...))
		t[k] = bool[0]
		return result:unpack()
	end
end

-- TODO atypical igInputText since it uses a string


-- this is tooltip wrap + table wrap
iglua.luatableTooltipSliderFloat = makeWrapTooltip(iglua.luatableSliderFloat)
iglua.luatableTooltipInputFloat = makeWrapTooltip(iglua.luatableInputFloat)
iglua.luatableTooltipCombo = makeWrapTooltip(iglua.luatableCombo)
iglua.luatableTooltipCheckbox = makeWrapTooltip(iglua.luatableCheckbox)
iglua.luatableTooltipRadioButton = makeWrapTooltip(iglua.luatableRadioButton)

return setmetatable(iglua, {
	__index = ig,
})

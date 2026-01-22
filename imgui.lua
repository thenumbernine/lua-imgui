--[[
TODO move this into ffi.imgui because I'm using it so much
same as the non-C part of my lua-ffi-bindings, same as hydro-cl/hydro/toolkit
--]]
local ffi = require 'ffi'
local ig = require 'imgui.ffi.imgui'
local table = require 'ext.table'
local assert = require 'ext.assert'

require 'ffi.req' 'c.string'	--strlen

-- ig interface but with lua tables
local iglua = {}

local ImVec2 = ffi.metatype('ImVec2', {
	__tostring = function(self)
		return '{'..self.x..', '..self.y..'}'
	end,
	__concat = function(self, other)
		return tostring(self) .. tostring(other)
	end,
})
iglua.ImVec2 = ImVec2
local ImVec4 = ffi.metatype('ImVec4', {
	__tostring = function(self)
		return '{'..self.x..', '..self.y..', '..self.z..', '..self.w..'}'
	end,
	__concat = function(self, other)
		return tostring(self) .. tostring(other)
	end,
})
iglua.ImVec4 = ImVec4



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
	local ctype3 = type3 == 'ctype' and tostring(ffi.typeof(arg3))
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
	local desc, col, flags, size = ...
	if type(col) == 'table' then col = ImVec4(table.unpack(col,1,4)) end
	if n < 3 then flags = 0 end
	if n < 4 then size = ImVec2(16,16) end
	return ig.igColorButton(desc, col, flags, size)
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
	local user_texture_id, size, uv0, uv1 = ...
	if n < 3 then uv0 = ImVec2(0,0) end
	if n < 4 then uv1 = ImVec2(1,1) end
	return ig.igImage(user_texture_id, size, uv0, uv1)
end
function iglua.igImageWithBg(...)
	local n = select('#', ...)
	local user_texture_id, size, uv0, uv1, tint_col, border_col = ...
	if n < 3 then uv0 = ImVec2(0,0) end
	if n < 4 then uv1 = ImVec2(1,1) end
	if n < 5 then tint_col = ImVec4(1,1,1,1) end
	if n < 6 then border_col = ImVec4(0,0,0,0) end
	return ig.igImageWithBg(user_texture_id, size, uv0, uv1, tint_col, border_col)
end
function iglua.igImageButton(...)
	local n = select('#', ...)
	local str_id, user_texture_id, size, uv0, uv1, bg_col, tint_col = ...
	if n < 4 then uv0 = ImVec2(0,0) end
	if n < 5 then uv1 = ImVec2(1,1) end
	if n < 6 then bg_col = ImVec4(0,0,0,0) end
	if n < 7 then tint_col = ImVec4(1,1,1,1) end
	return ig.igImageButton(str_id, user_texture_id, size, uv0, uv1, bg_col, tint_col)
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
	local label, v, v_min, v_max, display_format, flags = ...
	if n < 5 then display_format = '%.3f' end
	if n < 6 then flags = 0 end
	return ig.igSliderFloat(label, v, v_min, v_max, display_format, flags)
end
function iglua.igSliderFloat2(...)
	local n = select('#', ...)
	local label, v, v_min, v_max, display_format, flags = ...
	if n < 5 then display_format = '%.3f' end
	if n < 6 then flags = 0 end
	return ig.igSliderFloat2(label, v, v_min, v_max, display_format, flags)
end
function iglua.igSliderFloat3(...)
	local n = select('#', ...)
	local label, v, v_min, v_max, display_format, flags = ...
	if n < 5 then display_format = '%.3f' end
	if n < 6 then flags = 0 end
	return ig.igSliderFloat3(label, v, v_min, v_max, display_format, flags)
end
function iglua.igSliderFloat4(...)
	local n = select('#', ...)
	local label, v, v_min, v_max, display_format, flags = ...
	if n < 5 then display_format = '%.3f' end
	if n < 6 then flags = 0 end
	return ig.igSliderFloat4(label, v, v_min, v_max, display_format, flags)
end
function iglua.igSliderInt(...)
	local n = select('#', ...)
	local label, v, v_min, v_max, display_format, flags = ...
	if n < 5 then display_format = '%d' end
	if n < 6 then flags = 0 end
	return ig.igSliderInt(label, v, v_min, v_max, display_format, flags)
end
function iglua.igSliderInt2(...)
	local n = select('#', ...)
	local label, v, v_min, v_max, display_format, flags = ...
	if n < 5 then display_format = '%d' end
	if n < 6 then flags = 0 end
	return ig.igSliderInt2(label, v, v_min, v_max, display_format, flags)
end
function iglua.igSliderInt3(...)
	local n = select('#', ...)
	local label, v, v_min, v_max, display_format, flags = ...
	if n < 5 then display_format = '%d' end
	if n < 6 then flags = 0 end
	return ig.igSliderInt3(label, v, v_min, v_max, display_format, flags)
end
function iglua.igSliderInt4(...)
	local n = select('#', ...)
	local label, v, v_min, v_max, display_format, flags = ...
	if n < 5 then display_format = '%d' end
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
iglua.tooltipSliderFloat = makeWrapTooltip(iglua.igSliderFloat)
iglua.tooltipCombo = makeWrapTooltip(iglua.igCombo)
iglua.tooltipInputFloat = makeWrapTooltip(iglua.igInputFloat)
iglua.tooltipInputInt = makeWrapTooltip(iglua.igInputInt)
iglua.tooltipInputText = makeWrapTooltip(iglua.igInputText)
iglua.tooltipButton = makeWrapTooltip(iglua.igButton)
iglua.tooltipCheckbox = makeWrapTooltip(ig.igCheckbox)
iglua.tooltipRadioButton = makeWrapTooltip(ig.igRadioButton_IntPtr)	-- TODO instead of _IntPtr, replace with iglua.igRadioButton and do type detect

function iglua.tooltipText(label, str)
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
	local ctype = assert.index(args, 'ctype')
	local func = assert.index(args, 'func')
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

			-- should this write always?  or only when the imgui function returns true?
			-- 'always' will result in truncations of double to float
			if result[1] then
				t[k] = castfrom(ptr[0])
			end

			return result:unpack()
		end
	end
end

-- atypical luatableInputText / igInputText since it uses a string, and passes the string size
local function makeTableAccessString(args)
	local func = assert.index(args, 'func')
	local buf = ffi.new'char[256]'
	return function(title, t, k, ...)
		local src = tostring(t[k])
		local len = #src
		while len >= ffi.sizeof(buf) do
			local newbuf = ffi.new('char[?]', ffi.sizeof(buf) * 2)
			ffi.copy(newbuf, buf, ffi.sizeof(buf))
			buf = newbuf
		end
		ffi.copy(buf, src, len)
		buf[len] = 0
		local result = table.pack(func(title, buf, ffi.sizeof(buf), ...))
		if result[1] then
			t[k] = ffi.string(buf, math.min(ffi.sizeof(buf), tonumber(ffi.C.strlen(buf))))
		end
		return result:unpack()
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

-- TODO some want A, some want B ...
-- [[ this uses the imgui string-to-float
iglua.luatableInputFloat = makeTableAccess{
	ctype = 'float',
	func = iglua.igInputFloat,
	castto = tonumber,
}
--]]
-- [[ This uses lua's string-to-float
-- Sometimes you pass a small float to igInputFloat and it just renders .000... and nothing else.  This will format properly.  Yeah I know you can override formatting in igInputFloat .
-- This also handles inputs of 1e+ 1e- correctly.  Can igInputFloat do that?
-- notice this will trigger 'return true' for every keypress unless you pass ig.ImGuiInputTextFlags_EnterReturnsTrue as the next arg (in the ...)
function iglua.luatableInputFloatAsText(title, t, k, ...)
	local tmp = {value = tostring(t[k])}
	local result = table.pack(iglua.luatableInputText(title, tmp, 'value', ...))
	if result[1] then
		local v = tonumber(tmp.value)
		if v then
			t[k] = v
			return result:unpack()
		end
	end
	return result:unpack()
end
--]]

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
		assert.type(assert.index(t, k), 'number')
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
		assert.ne(t, nil)
		assert.ne(t[k], nil)
		bool[0] = t[k]
		local result = table.pack(iglua.igMenuItem(label, shortcut, bool, ...))
		t[k] = bool[0]
		return result:unpack()
	end
end

iglua.luatableInputText = makeTableAccessString{
	func = iglua.igInputText,
}

iglua.luatableInputTextMultiline = makeTableAccessString{
	func = iglua.igInputTextMultiline,
}

-- atypical since it's using a lua table
do
	local float3 = ffi.new'float[3]'
	function iglua.luatableColorEdit3(label, t, k, ...)	-- doesn't really need t[k], just v
		local v = t[k]
		float3[0] = v[1]
		float3[1] = v[2]
		float3[2] = v[3]
		local result = table.pack(iglua.igColorEdit3(label, float3, ...))
		v[1] = float3[0]
		v[2] = float3[1]
		v[3] = float3[2]
		return result:unpack()
	end

	function iglua.luatableColorPicker3(label, t, k, ...)	-- doesn't really need t[k], just v
		local v = t[k]
		float3[0] = v[1]
		float3[1] = v[2]
		float3[2] = v[3]
		local result = table.pack(iglua.igColorPicker3(label, float3, ...))
		v[1] = float3[0]
		v[2] = float3[1]
		v[3] = float3[2]
		return result:unpack()
	end
end

-- this is tooltip wrap + table wrap
iglua.luatableTooltipSliderFloat = makeWrapTooltip(iglua.luatableSliderFloat)
iglua.luatableTooltipInputFloat = makeWrapTooltip(iglua.luatableInputFloat)
iglua.luatableTooltipInputFloatAsText = makeWrapTooltip(iglua.luatableInputFloatAsText)
iglua.luatableTooltipInputInt = makeWrapTooltip(iglua.luatableInputInt)
iglua.luatableTooltipCombo = makeWrapTooltip(iglua.luatableCombo)
iglua.luatableTooltipCheckbox = makeWrapTooltip(iglua.luatableCheckbox)
iglua.luatableTooltipRadioButton = makeWrapTooltip(iglua.luatableRadioButton)
iglua.luatableTooltipInputText = makeWrapTooltip(iglua.luatableInputText)

-- https://github.com/ocornut/imgui/issues/3541
function iglua.fullscreen(cb, ytop)
	ytop = ytop or 0
	local IMGUI_HAS_VIEWPORT = true
	if IMGUI_HAS_VIEWPORT then
		local viewport = ig.igGetMainViewport()
		ig.igSetNextWindowPos(viewport.WorkPos, 0, ImVec2())
		ig.igSetNextWindowSize(viewport.WorkSize, 0)
		ig.igSetNextWindowViewport(viewport.ID)
	else
		-- TODO this 18 is to work around browser's url ...
		-- hmm ...
		-- how to offset / sub-context / sub-viewport / whatever ...
		-- maybe just have an arg to override from default of 0?
		ig.igSetNextWindowPos(ImVec2(0, ytop), 0, ImVec2())
		local size = ImVec2(ig.igGetIO().DisplaySize)
		size.y = size.y - ytop
		ig.igSetNextWindowSize(size, 0)
	end
	ig.igPushStyleVar_Float(ig.ImGuiStyleVar_WindowRounding, 0)
	ig.igBegin('MainViewport', nil, bit.bor(
		ig.ImGuiWindowFlags_NoMove,
		ig.ImGuiWindowFlags_NoResize,
		ig.ImGuiWindowFlags_NoCollapse,
		ig.ImGuiWindowFlags_NoDecoration
	))
	cb()
	ig.igEnd()
	ig.igPopStyleVar(1)
end

return setmetatable(iglua, {
	__index = ig,
})

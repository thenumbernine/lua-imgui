--[[
TODO move this into ffi.imgui because I'm using it so much
same as the non-C part of my lua-ffi-bindings, same as hydro-cl/hydro/toolkit
--]]
local ffi = require 'ffi'
local ig = require 'ffi.cimgui'
--local ig = require 'ffi.imgui'
local table = require 'ext.table'

-- ig interface but with lua tables
local iglua = {}

local ImVec2 = ffi.metatype('ImVec2', {})
iglua.ImVec2 = ImVec2
local ImVec4 = ffi.metatype('ImVec4', {})
iglua.ImVec4 = ImVec4 

local tmpbool = ffi.new'bool[1]'
local tmpfloat = ffi.new'float[1]'


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

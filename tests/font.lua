#!/usr/bin/env luajit

-- https://github.com/ocornut/imgui/blob/master/docs/FONTS.md
--  Trying to use custon fonts.
-- seems FontAtlas->Build() alone doesn't work, you gotta copy from ImGui the font tex data, make a GL tex out of it, then re-assign the GL tex back to ImGUi

local ImGuiApp = require 'imgui.app'
local ffi = require 'ffi'
local ig = require 'imgui'
local gl = require 'gl'

local fontFilename = ... or 'font.ttf'

local TestApp = ImGuiApp:subclass()

function TestApp:initGL(...)
	TestApp.super.initGL(self, ...)

-- [[
	self.fontAtlas = ig.ImFontAtlas_ImFontAtlas()
	--local fontConfig = ig.ImFontConfig_ImFontConfig()
	-- trying https://github.com/ocornut/imgui/issues/733
	-- "Cannot use MergeMode for the first font"
	--fontConfig.MergeMode = true
	--[[
	fontConfig.MergeMode = false
	fontConfig.OversampleH = 1
	fontConfig.OversampleV = 1
	fontConfig.PixelSnapH = true
	--]]
	--local glyphRanges = ig.ImFontAtlas_GetGlyphRangesDefault(self.fontAtlas)

print('fontAtlas', self.fontAtlas)
--print('fontConfig', fontConfig)
--print('glyphRanges', glyphRanges)
--]]

	self.font = ig.ImFontAtlas_AddFontFromFileTTF(
		self.fontAtlas,
		fontFilename,
		16,			-- font size
		nil,--fontConfig,
		nil--glyphRanges
	)
print('font', self.font)
	if self.font == nil then error("couldn't load font") end

-- [[ without this it crashes and complains that it's not built
-- but rebuilding doesn't rebuild, you just get white blobs.
	local built = ig.ImFontAtlas_Build(self.fontAtlas)
	print('font atlas built?', ig.ImFontAtlas_IsBuilt(self.fontAtlas))
--]]
--[[ doesn't help, still have to download/upload the texture image data
-- doesn't help when run before or after FontAtlas_Build
	ig.ImFontAtlas_ClearTexData(self.fontAtlas)
--]]
-- [[ instead you have to download the font texture pixel data, make a GL texture out of it, and re-upload it
	local width = ffi.new('int[1]')
	local height = ffi.new('int[1]')
	local bpp = ffi.new('int[1]')
	local outPixels = ffi.new('unsigned char*[1]')
	ig.ImFontAtlas_GetTexDataAsRGBA32(self.fontAtlas, outPixels, width, height, bpp)
	-- GL_LUMINANCE textures are deprecated ... meaning you have to write extra shaders for greyscale textures to be used as greyscale in opengl
	--ig.ImFontAtlas_GetTexDataAsAlpha8(self.fontAtlas, outPixels, width, height, bpp)
	print('font tex data width', width[0], height[0], bpp[0], outPixels[0])
	local GLTex2D = require 'gl.tex2d'
	self.fontTex = GLTex2D{
		internalFormat = gl.GL_RGBA,
		--internalFormat = gl.GL_RED,
		format = gl.GL_RGBA,
		--format = gl.GL_RED,
		width = width[0],
		height = height[0],
		type = gl.GL_UNSIGNED_BYTE,
		data = outPixels[0],
		minFilter = gl.GL_NEAREST,
		magFilter = gl.GL_NEAREST,
		wrap = {
			s = gl.GL_CLAMP_TO_EDGE,
			t = gl.GL_CLAMP_TO_EDGE,
		},
	}
	require 'ffi.req' 'c.stdlib'	-- free()
	ffi.C.free(outPixels[0])	-- just betting here I have to free this myself ...
	ig.ImFontAtlas_SetTexID(self.fontAtlas, ffi.cast('ImTextureID', self.fontTex.id))
--]]
	local io = ig.igGetIO()
print('io', io)
	
	-- can I just call this once here?  nope. needs to be every frame.
	--ig.igPushFont(self.font)
end

function TestApp:update(...)
	gl.glClearColor(.4, .8, .8, 1)
	gl.glClear(gl.GL_COLOR_BUFFER_BIT)

	TestApp.super.update(self, ...)
end

local checkbox = ffi.new('bool[1]', 1)
function TestApp:updateGUI()
	-- every frame? yup
	ig.igPushFont(self.font)
	ig.igBegin('test', nil, 0)
	ig.igText('Hello, world!')
	ig.igCheckbox('checkbox', checkbox)
	ig.igEnd()
	ig.igPopFont()
end

local testApp = TestApp()
return testApp:run()

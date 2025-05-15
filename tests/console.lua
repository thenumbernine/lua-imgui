#!/usr/bin/env luajit

local ig = require 'imgui'
local gl = require 'gl'
local table = require 'ext.table'

local env = setmetatable({}, {__index=_G})
if setfenv then setfenv(1,env) else _ENV = env end

env.env = env
App = require 'imgui.appwithorbit'()
App.title = 'Console Test'

function App:initGL(...)
	App.super.initGL(self, ...)

	self.consoleOpen = true
	self.buffer = ''
end

function App:update()
	gl.glClear(bit.bor(gl.GL_COLOR_BUFFER_BIT, gl.GL_DEPTH_BUFFER_BIT))
	App.super.update(self)
end

function App:updateGUI()
	if ig.igBeginMainMenuBar() then
		if ig.igBeginMenu'File' then
			ig.luatableMenuItem('Console', nil, self, 'consoleOpen')
			ig.igEndMenu()
		end
		ig.igEndMainMenuBar()
	end

	if self.consoleOpen then
		ig.luatableBegin('Console', self, 'consoleOpen')
		local size = ig.igGetWindowSize()
		if ig.luatableInputTextMultiline('code', self, 'buffer',
			ig.ImVec2(size.x,size.y - 56),
			ig.ImGuiInputTextFlags_EnterReturnsTrue
			+ ig.ImGuiInputTextFlags_AllowTabInput)
		or ig.igButton('run code')
		then
			
			print('executing...\n'..self.buffer)
			local f, err = load(self.buffer, nil, nil, env)
			if not f then
				print(err)
			else
				local res = table.pack(pcall(f))
				if not res:remove(1) then
					print(res[1])
				else
					res.n = res.n - 1	-- remove() doesn't do this
					if res.n > 0 then
						print(res:unpack())
					end
				end
			end
		end
		ig.igSameLine()
		if ig.igButton('clear code') then
			self.buffer = ''
		end
		ig.igEnd()
	end
end

return App():run()

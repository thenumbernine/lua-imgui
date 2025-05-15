--[[
I do this often enough that I'll put it in one place here
I am returning it as a function so that it can be run multiple times without caching the result as unique .
--]]
local OrbitBehavior = require 'glapp.orbit'
local ImGuiApp = require 'imguiapp'
return function(args)
	return OrbitBehavior(ImGuiApp):subclass(args)
end

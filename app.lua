local GLApp = require 'gl.app'
local ig = require 'imgui'
local gl = require 'gl'

local ImGuiApp = GLApp:subclass()

local loaded2 = package.loaded['sdl.app2']
local loaded3 = package.loaded['sdl.app3']
local SDL = loaded2 and 'SDL2' or loaded3 and 'SDL3' or error("I can't tell your SDL version")

function ImGuiApp:initGL()
	self.imguiCtx = ig.igCreateContext(nil)
    ig['ImGui_Impl'..SDL..'_InitForOpenGL'](self.window, self.sdlCtx)
    ig.ImGui_ImplOpenGL3_Init(self.glslVersion)	-- nil => null => default
	ig.igStyleColorsDark(nil)
end

function ImGuiApp:exit()
    ig.ImGui_ImplOpenGL3_Shutdown()
    ig['ImGui_Impl'..SDL..'_Shutdown']()
    ig.igDestroyContext(self.imguiCtx)

	ImGuiApp.super.exit(self)
end

function ImGuiApp:event(eventPtr)
	assert(eventPtr, "forgot to pass the eventPtr")
	ig['ImGui_Impl'..SDL..'_ProcessEvent'](eventPtr)
end

function ImGuiApp:update()
    ig.ImGui_ImplOpenGL3_NewFrame()
    ig['ImGui_Impl'..SDL..'_NewFrame']()
    ig.igNewFrame()

	self:updateGUI()

	--glViewport(0, 0, (int)ImGui::GetIO().DisplaySize.x, (int)ImGui::GetIO().DisplaySize.y)
	gl.glViewport(0, 0, self.width, self.height)

    ig.igRender()
    ig.ImGui_ImplOpenGL3_RenderDrawData(ig.igGetDrawData())
end

function ImGuiApp:updateGUI()
end

return ImGuiApp

package = "imgui"
version = "dev-1"
source = {
	url = "git+https://github.com/thenumbernine/lua-imgui.git"
}
description = {
	summary = "LuaJIT C-ImGui Wrapper",
	detailed = "LuaJIT C-ImGui Wrapper",
	homepage = "https://github.com/thenumbernine/lua-imgui",
	license = "MIT",
}
dependencies = {
	"lua >= 5.1",
}
build = {
	type = "builtin",
	modules = {
		imgui = "imgui.lua"
	}
}

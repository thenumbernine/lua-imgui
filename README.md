[![paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=KYWUWS86GSFGL)

## LuaJIT C-ImGui Wrapper

This holds some C++-overloaded-operator API wrappers of the cimgui LuaJIT function calls.
It also holds some lua-table-to-C-pointer wrappers.
And for kicks it has some wrappers for showing the text as a hover label instead of next to the widget.

Dependencies:
- [lua-ext](https://github.com/thenumbernine/lua-ext)
- [lua-ffi-bindings](https://github.com/thenumbernine/lua-ffi-bindings)
- [cimgui](https://github.com/cimgui/cimgui)

I'm currently using the cimgui v1.87dock API.

Build this with its `backends/imgui_impl_sdl.cpp` and `backends/imgui_impl_opengl2.cpp` added to the project.
Also for Linux, sure to set in the cimgui Makefile: `CXXFLAGS += "-DIMGUI_IMPL_API=extern \"C\""`

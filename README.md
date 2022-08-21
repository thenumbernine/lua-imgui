I have wrote lua-to-C interop stuff enough for my cimgui bindings that I think I'll put it here.

It used to reside in my lua-ffi-bindings project, but I'm turning that more and more into code generated from my preproc-lua project.

Dependencies:
- [lua-ext](https://github.com/thenumbernine/lua-ext)
- [lua-ffi-bindings](https://github.com/thenumbernine/lua-ffi-bindings)
- [cimgui](https://github.com/cimgui/cimgui)

I'm currently using the cimgui v1.87dock API.

Build this with its `backends/imgui_impl_sdl.cpp` and `backends/imgui_impl_opengl2.cpp` added to the project.
Also for Linux, sure to set in the cimgui Makefile: `CXXFLAGS += "-DIMGUI_IMPL_API=extern \"C\""`

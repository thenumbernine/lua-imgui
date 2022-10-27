[![Donate via Stripe](https://img.shields.io/badge/Donate-Stripe-green.svg)](https://buy.stripe.com/00gbJZ0OdcNs9zi288)<br>
[![Donate via Bitcoin](https://img.shields.io/badge/Donate-Bitcoin-green.svg)](bitcoin:37fsp7qQKU8XoHZGRQvVzQVP8FrEJ73cSJ)<br>

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

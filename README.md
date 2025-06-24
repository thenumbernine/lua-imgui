[![Donate via Stripe](https://img.shields.io/badge/Donate-Stripe-green.svg)](https://buy.stripe.com/00gbJZ0OdcNs9zi288)<br>

# LuaJIT C-ImGui Wrapper

This holds some C++-overloaded-operator API wrappers of the cimgui LuaJIT function calls.
It also holds some lua-table-to-C-pointer wrappers.
And for kicks it has some wrappers for showing the text as a hover label instead of next to the widget.

Dependencies:
- [lua-ext](https://github.com/thenumbernine/lua-ext)
- [lua-ffi-bindings](https://github.com/thenumbernine/lua-ffi-bindings)
- [cimgui](https://github.com/cimgui/cimgui)

I'm currently using the cimgui v1.91.9dock API.

## cimgui build instructions:

```
git clone https://github.com/cimgui/cimgui
cd cimgui
git checkout tags/1.91.9dock
git submodule update --init --recursive

# now change the Makefile in cimgui:
# apply these changes to the Makefile in the cimgui base folder:
	OBJS += ./imgui/backends/imgui_impl_sdl2.o
	OBJS += ./imgui/backends/imgui_impl_opengl3.o
	CXXFLAGS += -DIMGUI_IMPL_API=extern\ \"C\"
	CXXFLAGS += -Iwherever/you/put/the/SDL2/include
	CXXFLAGS += -lSDL2
	OUTPUTNAME = libcimgui_sdl.so

# then build:
make all

# then install libcimgui_sdl.so somewhere where your OS or applications will find libraries.
```

# LuaJIT ImGui GLApp wrapper:

Also included is a subclass of GLApp that uses ImGui.

### Dependencies:

- [lua-ext](https://github.com/thenumbernine/lua-ext)
- [lua-gl](https://github.com/thenumbernine/lua-gl)
- [lua-glapp](https://github.com/thenumbernine/lua-glapp)
- [lua-imgui](https://github.com/thenumbernine/lua-imgui)
- [lua-ffi-bindings](https://github.com/thenumbernine/lua-ffi-bindings)

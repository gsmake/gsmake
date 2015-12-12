#ifndef LEMOON_LEMOON_H
#define LEMOON_LEMOON_H

#ifdef __cplusplus
#include <lua/lua.hpp>
#else
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
#endif //

#include <lemon/config.h>

EXTERN_C int luaopen_lemoon_fs(lua_State *L);
EXTERN_C int luaopen_lemoon_log(lua_State *L);
EXTERN_C int luaopen_lemoon_os(lua_State *L);
EXTERN_C int luaopen_lemoon_regex(lua_State *L);
EXTERN_C int luaopen_lemoon_uuid(lua_State *L);

EXTERN_C int luaopen_lemoon(lua_State *L);

#endif //LEMOON_LEMOON_H
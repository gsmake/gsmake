#include "lemoon.h"
#include <sqlite/lsqlite3.h>


EXTERN_C int luaopen_lemoon(lua_State *L)
{

    luaL_requiref(L,"lemoonc.fs",luaopen_lemoon_fs,1);
    luaL_requiref(L,"lemoonc.log",luaopen_lemoon_log,1);
    luaL_requiref(L,"lemoonc.os",luaopen_lemoon_os,1);
    luaL_requiref(L,"lemoonc.regex",luaopen_lemoon_regex,1);
    luaL_requiref(L,"lemoonc.sqlite3",luaopen_lsqlite3,1);
	luaL_requiref(L, "lemoonc.uuid", luaopen_lemoon_uuid, 1);

    return 0;
}
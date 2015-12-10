#include "lemoon.h"
#include <sqlite/lsqlite3.h>


EXTERN_C int luaopen_lemoon(lua_State *L)
{

    luaL_requiref(L,"lemoonc.fs",luaopen_lemoon_fs,0);
    luaL_requiref(L,"lemoonc.log",luaopen_lemoon_log,0);
    luaL_requiref(L,"lemoonc.os",luaopen_lemoon_os,0);
    luaL_requiref(L,"lemoonc.regex",luaopen_lemoon_regex,0);
    luaL_requiref(L,"lemoonc.sqlite3",luaopen_lsqlite3,0);

    return 0;
}
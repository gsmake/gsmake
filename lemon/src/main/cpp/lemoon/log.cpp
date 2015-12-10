#include <iostream>
#include <lua/lua.hpp>
#include <lemon/log/log.hpp>
#include <lemon/fs/filepath.hpp>

#include <lemoon/lemoon.h>


namespace lemoon{namespace log{

    int lua_get(lua_State *L)
    {
        auto& source = lemon::log::get(luaL_checkstring(L,1));

        lua_pushlightuserdata(L,(void*)&source);

        return 1;
    }

    int lua_log(lua_State *L)
    {
        luaL_checktype(L,1,LUA_TLIGHTUSERDATA);

        auto source = (const lemon::log::logger*)lua_touserdata(L,1);

        auto msg = luaL_checkstring(L,3);

        lua_Debug debug;

        lua_getstack(L,2, &debug);

        lua_getinfo(L,"lS", &debug);

        auto file = lemon::fs::filepath(debug.source + 1).filename();

        source->write((lemon::log::level)luaL_checkinteger(L,2), msg,file.string().c_str(),debug.currentline);

        return 0;
    }

    int lua_log_close(lua_State *L)
    {
        lemon::log::close();

        return 0;
    }

    static luaL_Reg funcs[] = {
        {"get",lua_get},
        {"log",lua_log},
        {"close",lua_log_close},
        {NULL, NULL}
    };

}}


int luaopen_lemoon_log(lua_State *L)
{
    luaL_newlib(L, lemoon::log::funcs);
    return 1;
}
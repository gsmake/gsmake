#include <regex>
#include <lua/lua.hpp>
#include "lemoon.h"

namespace lemoon{namespace regex{

    int gsub(lua_State *L)
    {
        std::string source = luaL_checkstring(L,1);

        std::regex regex(luaL_checkstring(L,2));

        auto result = std::regex_replace(source,regex,luaL_checkstring(L,3));

        lua_pushstring(L,result.c_str());

        return 1;
    }

    static luaL_Reg funcs[] = {
        { "gsub", gsub},

        {NULL, NULL}
    };

}}


EXTERN_C int luaopen_lemoon_regex(lua_State *L)
{
    luaL_newlib(L, lemoon::regex::funcs);
    return 1;
}
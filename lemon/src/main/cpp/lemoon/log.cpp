#include <iostream>
#include <lua/lua.hpp>
#include <lemon/log/log.hpp>
#include <lemon/fs/filepath.hpp>

#include <regex>
#include <lemoon/lemoon.h>
#include <lemon/strings.hpp>

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

        lua_getstack(L,3, &debug);

        lua_getinfo(L,"lS", &debug);

        auto file = lemon::fs::filepath(debug.source + 1).filename();

        source->write((lemon::log::level)luaL_checkinteger(L,2), msg,file.string().c_str(),debug.currentline);

        return 0;
    }

	int lua_file_sink(lua_State *L)
	{

		using namespace lemon::log;

		std::string sources = luaL_checkstring(L,1);

		lemon::log::file_sink* filesink;

		if(sources.empty())
		{
			filesink = new file_sink(luaL_checkstring(L, 2), luaL_checkstring(L, 3));
		}
		else
		{
			std::regex regex("\\s+");
			std::sregex_token_iterator first{ sources.begin(), sources.end(), regex, -1 },last;

			filesink = new file_sink({ first, last },luaL_checkstring(L, 2), luaL_checkstring(L, 3));
		}

		filesink->time_suffix(false);

		lemon::log::add_sink(std::unique_ptr<sink>(filesink));
		
		return 0;
	}

	int lua_console_sink(lua_State *L)
	{
		using namespace lemon::log;

		std::string sources = luaL_checkstring(L, 1);

		lemon::log::sink* filesink;

		if (sources.empty())
		{
			filesink = new console();
		}
		else
		{
			std::regex regex("\\s+");
			std::sregex_token_iterator first{ sources.begin(), sources.end(), regex, -1 }, last;

			filesink = new console({ first, last });
		}

		lemon::log::add_sink(std::unique_ptr<sink>(filesink));

		return 0;
	}

    int lua_log_close(lua_State *)
    {
        lemon::log::close();

        return 0;
    }

    static luaL_Reg funcs[] = {
        {"get",lua_get},
        {"log",lua_log},
        {"close",lua_log_close},
		{"file_sink",lua_file_sink},
		{"console_sink",lua_console_sink },
        {NULL, NULL}
    };

}}


int luaopen_lemoon_log(lua_State *L)
{
    luaL_newlib(L, lemoon::log::funcs);
    return 1;
}
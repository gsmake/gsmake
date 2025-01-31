//
// Created by liyang on 15/11/13.
//

#include <sstream>
#include <iostream>
#include <lemoon/lemoon.h>
#include <lemon/fs/fs.hpp>
#include <lemon/os/sysinfo.hpp>
#include <lemon/log/log.hpp>

int pmain(lua_State *L)
{
    auto path = lemon::os::getenv("GSMAKE_HOME");


    if(!std::get<1>(path))
    {
        return luaL_error(L,"GSMAKE_HOME env not found");
    }

    auto home = lemon::fs::filepath(std::get<0>(path));

    std::stringstream stream;

    stream << "package.path = '" << home.generic_string() << "/lib/gsmake/?.lua;" << home.generic_string() << "/lib/gsmake/?/init.lua'";

    if(luaL_dostring(L,stream.str().c_str()))
    {
        return luaL_error(L,lua_tostring(L,-1));
    }


    auto mainFile = home / "/lib/gsmake/main.lua";

    if(luaL_dofile(L, mainFile.generic_string().c_str()))
    {
        return luaL_error(L,lua_tostring(L,-1));
    }

    return 0;
}

static void createargtable(lua_State *L, char **argv, int argc) {
    int i, narg;
    narg = argc - 1; /* number of positive indices */
    lua_createtable(L, narg, 0);
    for (i = 1; i < argc; i++) {
        lua_pushstring(L, argv[i]);
        lua_rawseti(L, -2, i);
    }

    lua_setglobal(L, "arg");
}

int main(int args, char** argv) {

	lemon::log::add_sink(std::unique_ptr<lemon::log::sink>(new lemon::log::console({ "console" })));

	auto& console = lemon::log::get("console");
	auto& logger = lemon::log::get("gsmake");

    lua_State *L = luaL_newstate();

    createargtable(L, argv, args);

    luaL_openlibs(L);

    lua_pushcfunction(L, luaopen_lemoon);

    if (0 != lua_pcall(L, 0, 0, 0)) {
		std::string err = lua_tostring(L, -1);

        lemonE(logger,"panic:\n\t%s", err.c_str());
		lemonE(console, "panic:\n\t%s", err.c_str());
		lemonE(console, "for more details, check the log files in directory: ${WORKSPACE}/.gsmake/log");

		goto CLOSE;
    }

    lua_pushcfunction(L, pmain);

    if (0 != lua_pcall(L, 0, 0, 0)) {

		std::string err = lua_tostring(L, -1);

		lemonE(logger, "panic:\n\t%s", err.c_str());
		lemonE(console, "panic:\n\t%s", err.c_str());
		lemonE(console, "for more details, check the log files in directory: ${WORKSPACE}/.gsmake/log");

		goto CLOSE;
    }

CLOSE:

    lemon::log::close();

    lua_close(L);
}
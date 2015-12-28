#include <iostream>

#include <lua/lua.hpp>

#include <lemon/os/os.hpp>

#include "lemoon.h"



#define EXEC_CLASS_NAME "__lemoon_exec"

namespace lemoon { namespace os{

    int hostname(lua_State *L)
    {
        auto name = lemon::os::hostname();

        using host_t = lemon::os::host_t;

        switch(name)
        {
        case  host_t::Unknown:
            lua_pushstring(L,"Unknown");
            break;
        case  host_t::Win64:
            lua_pushstring(L,"Win64");
            break;
        case  host_t::Win32:
            lua_pushstring(L,"Win32");
            break;
        case  host_t::Linux:
            lua_pushstring(L,"Linux");
            break;
        case  host_t::Solaris:
            lua_pushstring(L,"Solaris");
            break;
        case  host_t::HPUX:
            lua_pushstring(L,"HPUX");
            break;
        case  host_t::AIX:
            lua_pushstring(L,"AIX");
            break;
        case  host_t::iOS_Simulator:
            lua_pushstring(L,"iOS_Simulator");
            break;
        case  host_t::iOS:
            lua_pushstring(L,"iOS");
        case  host_t::OSX:
            lua_pushstring(L,"OSX");
            break;
        case  host_t::OSX_Unknown:
            lua_pushstring(L,"OSX_Unknown");
        case host_t::Android:
            lua_pushstring(L,"Android");
            break;
        }

        return 1;
    }

    int lua_exec_start(lua_State *L)
    {
        using command = lemon::os::exec;

        auto cmd = (command*) luaL_checkudata(L,1,EXEC_CLASS_NAME);

        std::vector<std::string> args;

        for(int i = 2;; i ++)
        {
            if(lua_type(L,i) == LUA_TNONE || lua_type(L,i) == LUA_TNIL)
            {
                break;
            }

            args.push_back(luaL_checkstring(L,i));
        }

        try
        {
            cmd->start(args);
        }
        catch(const std::exception &e)
        {
            return luaL_error(L,"call lemon::os::exec#start method error :%s",e.what());
        }



        return 0;
    }

    int lua_exec_wait(lua_State *L)
    {
        using command = lemon::os::exec;

        auto cmd = (command*) luaL_checkudata(L,1,EXEC_CLASS_NAME);

        lua_pushinteger(L,cmd->wait());

        return 1;
    }

    int exec_dir(lua_State *L)
    {
        using command = lemon::os::exec;

        auto cmd = (command*) luaL_checkudata(L,1,EXEC_CLASS_NAME);

        cmd->work_path(luaL_checkstring(L,2));

        return 0;
    }

    static luaL_Reg exec[] = {
        {"start",lua_exec_start},
        {"dir",exec_dir},
        {"wait",lua_exec_wait},
        {NULL, NULL}
    };

    int lua_exec_close(lua_State *L)
    {
        using command = lemon::os::exec;

        auto cmd = (command*) luaL_checkudata(L,1,EXEC_CLASS_NAME);

        cmd->~command();

        return 0;
    }

    int lua_exec(lua_State *L)
    {
        using command = lemon::os::exec;

        auto buff = lua_newuserdata(L,sizeof(command));

        new(buff) command(luaL_checkstring(L,1));

        if (luaL_newmetatable(L, EXEC_CLASS_NAME)) {
            lua_newtable(L);

            luaL_setfuncs(L, exec, 0);

            lua_setfield(L, -2, "__index");

            lua_pushcfunction(L, lua_exec_close);

            lua_setfield(L, -2, "__gc");
        }

        lua_setmetatable(L, -2);

        return 1;
    }

    int lookup(lua_State *L)
    {
        auto result = lemon::os::lookup(luaL_checkstring(L,1));

        if(std::get<1>(result))
        {
            lua_pushboolean(L,true);

            lua_pushstring(L,std::get<0>(result).c_str());

            return 2;
        }

        lua_pushboolean(L,false);

        return 1;
    }

    int tmpdir(lua_State *L)
    {
        lua_pushstring(L,lemon::os::tmpdir().c_str());

        return 1;
    }


    static luaL_Reg os[] = {
        {"lookup",lookup},
        {"exec",lua_exec},
        {"host",hostname},
        {"tmpdir",tmpdir},
        {NULL, NULL}
    };
}}

EXTERN_C int luaopen_lemoon_os(lua_State *L)
{
    luaL_newlib(L, lemoon::os::os);

    return 1;
}

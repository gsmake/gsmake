#include <iostream>

#include <lua/lua.hpp>
#include <lemon/fs/fs.hpp>
#include <lemon/log/log.hpp>

#include "lemoon.h"

namespace lemoon{namespace{


    int pwd(lua_State *L)
    {
        if(lua_type(L,1) == LUA_TNONE || lua_type(L,1) == LUA_TNIL)
        {
            std::error_code err;
            auto curr = lemon::fs::current_path(err);

            if (err)
            {
                return luaL_error(L,"[lemoon.fs] call lemon::fs::current_directory error :%s",err.message().c_str());
            }

            lua_pushstring(L,curr.string().c_str());

            return 1;
        }
        else
        {
            const char * path = luaL_checkstring(L,1);

            std::error_code err;

            lemon::fs::current_path(path,err);

            if (err)
            {
                return luaL_error(L,"[lemoon.fs] call lemon::fs::set_current_directory error :%s",err.message().c_str());
            }

        }

        return 0;
    }

    int exists(lua_State *L)
    {
        if(lemon::fs::exists(luaL_checkstring(L,1)))
        {
            lua_pushboolean(L,1);
        }
        else
        {
            lua_pushboolean(L,0);
        }

        return 1;
    }

    int is_dir(lua_State *L)
    {
        if(lemon::fs::is_directory(luaL_checkstring(L,1)))
        {
            lua_pushboolean(L,1);
        }
        else
        {
            lua_pushboolean(L,0);
        }

        return 1;
    }

    int mkdir(lua_State *L)
    {
        std::error_code err;

        if(lua_type(L,2) == LUA_TBOOLEAN && lua_toboolean(L,2))
        {
			auto path = luaL_checkstring(L, 1);
            lemon::fs::create_directories(path,err);

            if(err)
            {
                return luaL_error(L,"[lemoon.fs] call emon::fs::create_directories error :%s",err.message().c_str());
            }

            return 0;
        }

        lemon::fs::create_directory(luaL_checkstring(L,1),err);


        if (err)
        {
            return luaL_error(L,"[lemoon.fs] call emon::fs::create_directory error :%s",err.message().c_str());
        }

        return 0;
    }

    int rm(lua_State *L)
    {
        std::error_code err;

        auto path = luaL_checkstring(L,1);

        if(lua_type(L,2) == LUA_TBOOLEAN && lua_toboolean(L,2) )
        {
            if(lemon::fs::is_directory(path) && !lemon::fs::is_symlink(path))
            {
                lemon::fs::remove_directories(path,err);

                if(err)
                {
                    return luaL_error(L,"[lemoon.fs] call emon::fs::remove_directories error :%s",err.message().c_str());
                }

                return 0;
            }
        }

        lemon::fs::remove_file(luaL_checkstring(L,1),err);

        if(err)
        {
            return luaL_error(L,"[lemoon.fs] remove file(%s) error :%s",path,err.message().c_str());
        }

        return 0;
    }

    int abs(lua_State *L)
    {
        auto fullPath = lemon::fs::absolute(luaL_checkstring(L,1));

        lua_pushstring(L,fullPath.string().c_str());

        return 1;
    }

    int symlink(lua_State *L)
    {
        std::error_code err;

        lemon::fs::create_symlink(luaL_checkstring(L,1),luaL_checkstring(L,2),err);

        if(err)
        {
            return luaL_error(L,"[lemoon.fs] call emon::fs::create_symlink error :%s",err.message().c_str());
        }

        return 0;
    }

    int list(lua_State *L)
    {
        luaL_checktype(L, 2, LUA_TFUNCTION);

        std::error_code err;

        try
        {

			if(!lemon::fs::is_directory(luaL_checkstring(L,1)))
			{
				return 0;
			}

            auto iter = lemon::fs::directory_iterator(luaL_checkstring(L,1));


            while(iter.has_next())
            {
                lua_pushvalue(L, 2);

                lua_pushstring(L, iter().string().c_str());

                if (0 != lua_pcall(L, 1, 0, 0))
                {
                    return luaL_error(L,"[lemoon.fs] invoke list callback error :%s",lua_tostring(L,-1));
                }
            }

            return 0;
        }
        catch(const std::system_error &e)
        {
            return luaL_error(L,"[lemoon.fs] call emon::fs::read_directory error :%s",e.what());
        }
    }

	int copy_file(lua_State *L)
	{
		lemon::fs::copy_options options = lemon::fs::copy_options::none;
		
		if (lua_type(L, 3) != LUA_TNONE && lua_type(L, 3) != LUA_TNIL)
		{
			options = (lemon::fs::copy_options)luaL_checkinteger(L, 3);
		}
		std::error_code err;
		lemon::fs::copy_file(luaL_checkstring(L, 1), luaL_checkstring(L, 2), options, err);

		if (err)
		{
			luaL_error(L, "[lemoon.fs] %s", err.message().c_str());
		}

		return 0;
	}


    static luaL_Reg funcs[] = {
        {"list",list},
        {"symlink",symlink},
        {"abs",abs},
        {"dir",pwd},
        {"isdir",is_dir},
        {"exists",exists},
        {"mkdir",mkdir},
		{"copy_file",copy_file},
        {"rm",rm},
        {NULL, NULL}
    };
}}

EXTERN_C int luaopen_lemoon_fs(lua_State *L)
{
    luaL_newlib(L, lemoon::funcs);

    return 1;
}
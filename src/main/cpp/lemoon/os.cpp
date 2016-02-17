

#include <mutex>
#include <locale>
#include <cassert>

#include <lua/lua.hpp>
#include <lemon/os/os.hpp>




auto & logger = lemon::log::get("lemoon");

#define EXEC_CLASS_NAME "__lemoon_exec"

namespace lemoon { namespace os{

	using namespace lemon::os;

    int hostname(lua_State *L)
    {
        auto name = lemon::os::hostname();

        using host_t = lemon::os::host_t;

        switch(name)
        {
        case  host_t::Unknown:
            lua_pushstring(L,"Unknown");
            break;
        case  host_t::Windows:
            lua_pushstring(L,"Windows");
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

	int arch(lua_State *L)
	{
		auto name = lemon::os::arch();

		using arch_t = lemon::os::arch_t;

		switch (name)
		{
		case arch_t::Alpha:
			lua_pushstring(L, "Alpha");
			break;
		case arch_t::AMD64:
			lua_pushstring(L, "AMD64");
			break;
		case arch_t::ARM:
			lua_pushstring(L, "ARM");
			break;
		case arch_t::ARM64:
			lua_pushstring(L, "ARM64");
			break;
		case arch_t::HP_PA:
			lua_pushstring(L, "HP_PA");
			break;
		case arch_t::MIPS:
			lua_pushstring(L, "MIPS");
			break;
		case arch_t::PowerPC:
			lua_pushstring(L, "PowerPC");
			break;
		case arch_t::SPARC:
			lua_pushstring(L, "SPARC");
			break;
		case arch_t::X86:
			lua_pushstring(L, "X86");
			break;
		}


		return 1;
	}

	class command : public lemon::os::exec
	{
	public:
		command(const std::string & name, lemon::os::exec_options options)
			:command(name, options, LUA_NOREF)
		{

		}
		command(const std::string & name, lemon::os::exec_options options,int out)
			:exec(name,options),_out(out)
		{

		}

		void callback(lua_State *L,const std::string & message)
		{
			if (_out != LUA_NOREF)
			{
				lua_rawgeti(L, LUA_REGISTRYINDEX, _out);

				assert(lua_type(L, -1) == LUA_TFUNCTION);

				lua_pushstring(L, message.c_str());

				if (0 != lua_pcall(L, 1, 0, 0))
				{
					lemonE(logger, "call exec output callback function error :%s", lua_tostring(L, -1));
				}
			}
		}


		void close(lua_State *L)
		{
			if(_out != LUA_NOREF)
			{
				luaL_unref(L, LUA_REGISTRYINDEX, _out);
			}
		}

	private:
		int						_out;
	};

    int lua_exec_start(lua_State *L)
    {
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
        auto cmd = (command*) luaL_checkudata(L,1,EXEC_CLASS_NAME);

		auto exit_code = cmd->wait();

        lua_pushinteger(L,exit_code);

        return 1;
    }

    int exec_dir(lua_State *L)
    {
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
        auto cmd = (command*) luaL_checkudata(L,1,EXEC_CLASS_NAME);

		cmd->close(L);

		cmd->~command();

        return 0;
    }

	void lua_exec_out_callback(lua_State *L,command * c)
	{

		static char recv_buff[1024];

		c->out().read(lemon::io::buff(recv_buff), [=](size_t trans, const std::error_code &err) {

			if (!err)
			{
				c->callback(L,std::string(recv_buff, recv_buff + trans));
				lua_exec_out_callback(L,c);

				return;
			}
		});
	}

	void lua_exec_err_callback(lua_State *L, command * c)
	{

		static char recv_buff[1024];

		c->err().read(lemon::io::buff(recv_buff), [=](size_t trans, const std::error_code &err) {

			if (!err)
			{
				c->callback(L,std::string(recv_buff, recv_buff + trans));
				lua_exec_err_callback(L, c);

				return;
			}
		});
	}

    int lua_exec(lua_State *L)
    {
		try
		{
			using namespace lemon::os;

			auto buff = lua_newuserdata(L, sizeof(command));

			exec_options options = exec_options::none;

			int callback = LUA_NOREF;

			if (lua_type(L, 2) == LUA_TFUNCTION)
			{
				options = exec_options((int)exec_options::pipe_error | (int)exec_options::pipe_out);

				lua_pushvalue(L, 2);
				callback = luaL_ref(L, LUA_REGISTRYINDEX);
			}

			auto cmd = new(buff) command(luaL_checkstring(L, 1), options, callback);

			if (lua_type(L, 2) == LUA_TFUNCTION)
			{
				lua_exec_out_callback(L, cmd);

				lua_exec_err_callback(L, cmd);
			}

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
		catch(const std::system_error &e)
		{
			return luaL_error(L, "call lemon::os::exec method error :%s", e.what());
		}
		
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
		{ "lookup",lookup },
		{ "exec",lua_exec },
		{ "host",hostname },
		{ "arch",arch },
		{ "tmpdir",tmpdir },
        {NULL, NULL}
    };
}}

EXTERN_C int luaopen_lemoon_os(lua_State *L)
{
    luaL_newlib(L, lemoon::os::os);

    return 1;
}

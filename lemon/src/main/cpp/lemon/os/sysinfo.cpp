
#include <locale>
#include <vector>

#include <stdlib.h>

#ifdef __APPLE__
#include <TargetConditionals.h>
#endif //

#include <lemon/fs/fs.hpp>
#include <lemon/strings.hpp>
#include <lemon/os/sysinfo.hpp>

namespace lemon { namespace os {
    typedef std::wstring_convert<std::codecvt<wchar_t, char, std::mbstate_t>, wchar_t> convert;

    host_t hostname()
    {

    #ifdef WIN32
        #ifdef _WIN64
                return host_t::Win64;
        #else
                return host_t::Win32;
        #endif
    #elif defined(__linux)
        #ifdef __android
            return host_t::Android;
        #else
            return host_t::Linux;
        #endif
    #elif defined(__sun)
        return host_t::Solaris;
    #elif defined(__hppa)
        return host_t::HPUX;
    #elif defined(_AIX)
        return host_t::AIX;
    #elif defined(__APPLE__)
    #if TARGET_OS_SIMULATOR == 1
        return host_t::iOS_Simulator;
    #elif TARGET_OS_IPHONE == 1
        return host_t::iOS;
    #elif TARGET_OS_MAC == 1
        return host_t::OSX;
    #else
        return host_t::OSX_Unknown;
    #endif
    #endif //WIN32
    }



    #ifdef WIN32
    std::tuple<std::string, bool> getenv(const std::string &name)
    {
        auto namew = convert().from_bytes(name);

        DWORD length = ::GetEnvironmentVariableW(namew.c_str(), NULL, 0);

        if(length == 0)
        {
            return std::make_tuple(std::string(), false);
        }

        std::vector<wchar_t> buff(length);

        ::GetEnvironmentVariableW(namew.c_str(), &buff[0], buff.size());

        return std::make_tuple(convert().to_bytes(&buff[0]), true);
    }
    #else

    std::tuple<std::string,bool> getenv(const std::string &name)
    {
        const char *val = ::getenv(name.c_str());

        if(val)
        {
            return std::make_tuple(std::string(val),true);
        }

        return std::make_tuple(std::string(), false);
    }

    #endif //WIN32


    std::string execute_suffix()
    {
    #ifdef WIN32
        return ".exe";
    #else
        return "";
    #endif
    }

#ifndef WIN32
    std::string tmpdir(std::error_code & )
    {
        auto val = getenv("TMPDIR");

        if(std::get<1>(val))
        {
            return std::get<0>(val);
        }
#ifdef __android
        return "/data/local/tmp";
#endif

        return "/tmp";
    }
#else


	std::string tmpdir(std::error_code & err)
	{
		wchar_t buff[MAX_PATH + 1];

		auto length = ::GetTempPathW(MAX_PATH, buff);

		if(length == 0)
		{
			err = std::error_code(GetLastError(),std::system_category());

			return "";
		}

		return convert().to_bytes(std::wstring(buff, buff + length));
	}
#endif


    std::tuple<std::string, bool> lookup(const std::string & cmd)
    {
        auto path = os::getenv("PATH");

        if(!std::get<1>(path))
        {
            return std::make_tuple(std::string(),false);
        }

    #ifdef WIN32
        const std::string delimiter = ";";
        const std::string extend = ".exe";
    #else
        const std::string delimiter = ":";
        const std::string extend = "";
    #endif //WIN32

        auto paths = strings::split(std::get<0>(path), delimiter);

    #ifdef WIN32
        DWORD length = ::GetSystemDirectoryW(0, 0);

            std::vector<wchar_t> buff(length);

            ::GetSystemDirectoryW(&buff[0], buff.size());

            paths.push_back(convert().to_bytes(&buff[0]));
    #else
    #endif

        for(auto p : paths)
        {
            auto fullPath = fs::filepath(p) / (cmd + extend);

            if(fs::exists(fullPath))
            {
                return std::make_tuple(fullPath.string(), true);
            }
        }

        return std::make_tuple(std::string(), false);
    }
}}
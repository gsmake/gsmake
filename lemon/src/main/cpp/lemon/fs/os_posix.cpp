#include <lemon/fs/os.hpp>


#ifndef WIN32

#include <unistd.h>


namespace lemon{ namespace fs {

    filepath current_path(std::error_code &e) noexcept
    {
        char *dir = getcwd(NULL,0);

        std::string current = dir;

        free(dir);

        return current;
    }

    void current_path(const filepath & path,std::error_code &err) noexcept
    {
        if (-1 == chdir(path.string().c_str()))
        {
            err = std::make_error_code((std::errc)errno);
        }
    }

    bool exists(const filepath & path) noexcept
    {
        struct stat info = {0};

        return stat(path.string().c_str(), &info) == 0;

    }

    void create_directory(const filepath& path,std::error_code & err) noexcept
    {
        if(mkdir(path.string().c_str(), ACCESSPERMS) != 0)
        {
            err = std::make_error_code((std::errc)errno);
        }
    }

    void create_symlink(const filepath &from, const filepath &to, std::error_code &err) noexcept
    {
        if( 0 != symlink(from.string().c_str(),to.string().c_str()))
        {
            err = std::make_error_code((std::errc)errno);
        }
    }


    bool is_directory(const filepath &source) noexcept
    {
        struct stat info = {0};

        if (stat(source.string().c_str(), &info) == 0) {

            if(S_ISDIR(info.st_mode)) {
                return true;
            }
        }

        return false;
    }

    void remove_file(const filepath & path ,std::error_code &err) noexcept
    {
        if (0 != remove(path.string().c_str()))
        {
            err = std::make_error_code((std::errc)errno);
        }
    }

}}
#endif //WIN32


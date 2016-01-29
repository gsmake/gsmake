#include <lemon/fs/os.hpp>


#ifndef WIN32

#include <cassert>
#include <array>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>


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

        void copy_file(const filepath & from,const filepath& to,std::error_code & errc) noexcept
        {
            const static std::size_t buff_size = 40960; // the default buff size is 4k

            std::array<char,buff_size> buff;

            int in =-1, out =-1;  // -1 means not open

            if ((in = ::open(from.string().c_str(), O_RDONLY))< 0)
            {
                errc = std::error_code(errno,std::system_category());
                return;
            }

            struct stat from_stat;
            if (::stat(from.string().c_str(), &from_stat)!= 0)
            {
                ::close(in);
                errc = std::error_code(errno,std::system_category());
                return;
            }


            int out_flag = O_CREAT | O_WRONLY | O_TRUNC | O_EXCL;

            if ((out = ::open(to.string().c_str(), out_flag, from_stat.st_mode))< 0)
            {
                errc = std::error_code(errno,std::system_category());

                ::close(in);

                return;
            }

            ssize_t sz, sz_read=1, sz_write;
            while (sz_read > 0
                    && (sz_read = ::read(in, &buff[0], buff.size())) > 0)
            {
                sz_write = 0;
                do
                {
                    assert(sz_read - sz_write > 0);  // #1

                    if ((sz = ::write(out, &buff[sz_write], (size_t)(sz_read - sz_write))) < 0)
                    {
                        sz_read = sz; // cause read loop termination
                        break;        //  and error reported after closes
                    }
                    assert(sz > 0);                  // #2
                    sz_write += sz;
                } while (sz_write < sz_read);
            }
        }

        std::uintmax_t file_size(const filepath& path, std::error_code& ec)
        {
            struct stat from_stat;
            if (::stat(path.string().c_str(), &from_stat)!= 0)
            {
                ec = std::error_code(errno,std::system_category());
                return 0;
            }

            return (std::uintmax_t)from_stat.st_size;
        }

    }
}
#endif //WIN32


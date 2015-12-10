#ifndef LEMON_OS_EXEC_HPP
#define LEMON_OS_EXEC_HPP


#include <vector>
#include <memory>
#include <utility>
#include <system_error>
#include <unordered_map>
#include <lemon/fs/fs.hpp>
#include <lemon/os/os_errors.hpp>
#include <lemon/os/sysinfo.hpp>

namespace lemon{ namespace os{

    class process;

    /**
     * start new command
     */
    void process_start(process &impl,std::error_code & err,const std::vector<std::string> & args) noexcept;

    /**
     * wait process exit
     */
    int process_wait(process &impl,std::error_code & err) noexcept ;

    /**
     * set the process work path
     */
    void process_work_path(process &proc,const fs::filepath & path, std::error_code & err) noexcept ;

    /**
     * get the process work path
     */
    fs::filepath process_work_path(process &proc) noexcept ;

    /**
     * set the new process env
     */
    template <typename Env>
    void process_env(process & proc, Env &&env);

    /**
     * get the process env
     */
    const std::unordered_map<std::string,std::string>& process_env(process & proc);



    class exec
    {
    public:
        exec(const std::string & name)
        {
            auto found = lookup(name);

            if(!std::get<1>(found))
            {
                throw std::system_error((int)errc::command_not_found,os_error_category());
            }

            _impl.reset(new process(std::get<0>(found)));
        }

        void work_path(const fs::filepath & path)
        {
            std::error_code err;

            process_work_path(*_impl,path,err);

            if (err)
            {
                throw std::system_error(err);
            }
        }

        template <typename ...Args>
        void start(Args &&...args)
        {
            start({std::forward<Args>(args)...});
        }

        void start(const std::vector<std::string> & args)
        {
            std::error_code err;
            process_start(*_impl,err,args);

            if (err)
            {
                throw std::system_error(err);
            }
        }

        int wait()
        {
            std::error_code err;
            auto code = process_wait(*_impl,err);
            if (err)
            {
                throw std::system_error(err);
            }

            return code;
        }


        template <typename ...Args>
        int run(Args &&...args)
        {
            start(std::forward<Args>(args)...);

            return wait();
        }

    private:
        std::unique_ptr<process>      _impl;
    };

}}

#endif //LEMON_OS_EXEC_HPP
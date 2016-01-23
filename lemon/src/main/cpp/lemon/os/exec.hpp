#ifndef LEMON_OS_EXEC_HPP
#define LEMON_OS_EXEC_HPP

#include <thread>
#include <vector>
#include <memory>
#include <utility>
#include <unordered_map>
#include <lemon/fs/fs.hpp>
#include <lemon/io/io.hpp>



#include <lemon/os/exec_options.hpp>
#include <lemon/os/os_errors.hpp>
#include <lemon/os/sysinfo.hpp>

using namespace std;

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
			:exec(name,exec_options::none)
        {
          
        }

		exec(const std::string & name, exec_options options)
			:_closed(false)
		{
			auto found = lookup(name);

			if (!std::get<1>(found))
			{
				throw std::system_error((int)errc::command_not_found, os_error_category());
			}

			if (((int)options & (int)exec_options::pipe_in))
			{
				_in.reset(new io::pipe(_ioservice));
			}

			if (((int)options & (int)exec_options::pipe_out))
			{
				_out.reset(new io::pipe(_ioservice));
			}

			if (((int)options & (int)exec_options::pipe_error))
			{
				_err.reset(new io::pipe(_ioservice));
			}

			if (exec_options::none != options)
			{
				auto call = [&](){
					while (!_closed)
					{
						std::error_code err;
						_ioservice.run_one(err);

						if (err)
						{
							if (err == lemon::io::errc::io_service_closed )
							{
								break;
							}
						}
					}

					for (;;)
					{
						std::error_code err;
						_ioservice.run_one(std::chrono::system_clock::duration(),err);

						if (err && err == std::errc::timed_out)
						{
							break;
						}
					}
				};


				_dispatcher = std::thread(call);
			}

			_impl.reset(new process(
				std::get<0>(found),
				_in?_in->in().get():io::handler(),
				_out?_out->out().get():io::handler(),
				_err?_err->out().get():io::handler()));
		}

		~exec()
		{
			_closed = true;
			_ioservice.notify_all();
			if(_dispatcher.joinable())
			{
				_dispatcher.join();
			}
			
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

		io::io_stream& in() const
		{
			return _in->out();
		}

		io::io_stream& out() const
		{
			return _out->in();
		}

		io::io_stream& err() const
		{
			return _err->in();
		}


    private:
		std::atomic<bool>				_closed;
        std::unique_ptr<process>		_impl;
		std::thread						_dispatcher;
		io::io_service					_ioservice;
		std::unique_ptr<io::pipe>		_in;
		std::unique_ptr<io::pipe>		_out;
		std::unique_ptr<io::pipe>		_err;

    };

}}

#endif //LEMON_OS_EXEC_HPP
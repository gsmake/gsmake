/**
 * 
 * @file     pipe
 * @brief    Copyright (C) 2015  yayanyang All Rights Reserved 
 * @author   yayanyang
 * @date     2015/12/07
 */
#ifndef LEMON_IO_PIPE_HPP
#define LEMON_IO_PIPE_HPP
#include <mutex>
#include <tuple>

#include <lemon/io/io_object_base.hpp>

namespace lemon { namespace io{

	
	template<typename Mutex>
	std::tuple<basic_io_stream<Mutex>*, basic_io_stream<Mutex>*>
		make_pipe(basic_io_service<Mutex> & service,std::error_code & err);

	template<typename Mutex>
	class basic_pipe 
	{
	public:

		basic_pipe(basic_io_service<Mutex> & io)
		{
			std::error_code err;

			auto pair = make_pipe(io,err);

			if(err)
			{
				throw std::system_error(err);
			}

			_in.reset(std::get<0>(pair));
			_out.reset(std::get<1>(pair));
		}

		basic_io_stream<Mutex>& in () const
		{
			return *_in;
		}

		basic_io_stream<Mutex>& out() const
		{
			return *_out;
		}

	private:
		std::unique_ptr<basic_io_stream<Mutex>>		_in;
		std::unique_ptr<basic_io_stream<Mutex>>		_out;
	};

	using pipe = basic_pipe<std::mutex>;
}}

#endif //LEMON_IO_PIPE_HPP
#ifndef LEMON_IO_HPP
#define LEMON_IO_HPP

#include <lemon/io/io_errors.hpp>

#ifdef WIN32
#include <lemon/io/pipe_iocp.hpp>
#include <lemon/io/io_object_iocp.hpp>
#include <lemon/io/io_service_iocp.hpp>
#elif defined(__linux)

#include <lemon/io/io_service_epoll.hpp>
#include <lemon/io/io_object_nio.hpp>
#include <lemon/io/pipe_posix.hpp>

#endif //WIN32


#include <lemon/io/pipe.hpp>
#include <lemon/io/handler.hpp>

#include <lemon/io/mutex_none.hpp>
#include <lemon/io/io_service.hpp>

namespace lemon{ namespace io{
	using io_service_s = basic_io_service<mutex_none>;
	using pipe_s = basic_pipe<mutex_none>;
	using io_stream_s = basic_io_stream<mutex_none>;
}}


#endif //LEMON_IO_HPP
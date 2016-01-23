#ifndef LEMON_IO_HPP
#define LEMON_IO_HPP

#include <lemon/io/io_errors.hpp>

#ifdef WIN32
#include <lemon/io/pipe_iocp.hpp>
#include <lemon/io/io_object_iocp.hpp>
#include <lemon/io/io_service_iocp.hpp>
#else

#include <lemon/io/reactor_io_pipe.hpp>
#include <lemon/io/reactor_io_stream.hpp>

#if defined(__linux)
#include <lemon/io/reactor_io_service_epoll.hpp>
#endif

#endif //WIN32



#include <lemon/io/handler.hpp>

#include <lemon/io/mutex_none.hpp>

namespace lemon{
    namespace io{

    }
}



#endif //LEMON_IO_HPP
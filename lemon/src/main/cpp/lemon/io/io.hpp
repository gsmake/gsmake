#ifndef LEMON_IO_HPP
#define LEMON_IO_HPP

#ifdef WIN32
#include <lemon/io/pipe_iocp.hpp>
#include <lemon/io/io_object_iocp.hpp>
#include <lemon/io/io_service_iocp.hpp>

#endif //WIN32


#include <lemon/io/pipe.hpp>
#include <lemon/io/io_service.hpp>

#endif //LEMON_IO_HPP
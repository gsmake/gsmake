/**
 *
 * @file     io_service_epoll
 * @brief    Copyright (C) 2015  yayanyang All Rights Reserved
 * @author   yayanyang
 * @date     2015/12/07
 */
#ifndef LEMON_IO_IO_SERVICE_EPOLL_HPP
#define LEMON_IO_IO_SERVICE_EPOLL_HPP

#include <unistd.h>
#include <sys/epoll.h>

#include <tuple>
#include <chrono>
#include <cerrno>
#include <system_error>
#include <lemon/log/log.hpp>
#include <lemon/config.h>
#include <lemon/nocopy.hpp>
#include <lemon/io/io_errors.hpp>
#include <lemon/io/reactor_io_service.hpp>

namespace lemon {
    namespace io {



    }
}

#endif //LEMON_IO_IO_SERVICE_EPOLL_HPP
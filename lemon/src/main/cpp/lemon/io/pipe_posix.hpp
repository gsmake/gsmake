/**
 *
 * @file     pipe_posix
 * @brief    Copyright (C) 2015  yayanyang All Rights Reserved
 * @author   yayanyang
 * @date     2015/12/07
 */
#ifndef LEMON_IO_PIPE_POSIX_HPP
#define LEMON_IO_PIPE_POSIX_HPP

#include <locale>
#include <memory>

#include <lemon/uuid.hpp>
#include <lemon/config.h>
#include <lemon/io/io_object_nio.hpp>

namespace lemon {namespace io {

        template<typename Mutex>
        std::tuple<basic_io_stream<Mutex>*, basic_io_stream<Mutex>*>
        make_pipe(basic_io_service<Mutex> & service, std::error_code & err)
        {
            return {};
        }
    }}

#endif //LEMON_IO_PIPE_POSIX_HPP
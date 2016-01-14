/**
 *
 * @file     io_service_epoll
 * @brief    Copyright (C) 2015  yayanyang All Rights Reserved
 * @author   yayanyang
 * @date     2015/12/07
 */
#ifndef LEMON_IO_IO_SERVICE_EPOLL_HPP
#define LEMON_IO_IO_SERVICE_EPOLL_HPP

#include <tuple>
#include <chrono>
#include <system_error>

#include <lemon/config.h>
#include <lemon/nocopy.hpp>
#include <lemon/io/io_errors.hpp>
#include <lemon/io/irp_base.hpp>

namespace lemon {
    namespace io {

        class io_service_impl : private nocopy
        {
        public:

            io_service_impl()
            {

            }

            void io_service_close() noexcept
            {

            }

            template<typename Duration>
            std::tuple<bool, handler, irp_op> io_service_poll(Duration timeout,std::error_code & err) noexcept
            {
                return {};
            }

            template<typename Object>
            void io_service_register(Object & obj, std::error_code & err) noexcept
            {

            }

            template<typename Object>
            void io_service_unregister(Object &) noexcept
            {

            }

            void io_service_complete(irp_base *irp, std::error_code & err) noexcept
            {

            }

            void notify_one(std::error_code & err) noexcept
            {

            }
        };

        template<typename Duration>
        std::tuple<bool, handler, irp_op> io_service_poll(io_service_impl &impl, Duration timeout,std::error_code & err) noexcept
        {
            return impl.io_service_poll(timeout, err);
        }

        template<typename Object>
        inline void io_service_register(io_service_impl &impl, Object & obj, std::error_code & err) noexcept
        {
            impl.io_service_register(obj, err);
        }

        template<typename Object>
        inline void io_service_unregister(io_service_impl &impl, Object & obj) noexcept
        {
            impl.io_service_unregister(obj);
        }

        inline void io_service_complete(io_service_impl &impl, irp_base *irp, std::error_code & err) noexcept
        {
            impl.io_service_complete(irp,err);
        }

        inline void io_service_close(io_service_impl &impl) noexcept
        {
            impl.io_service_close();
        }

        inline void io_service_notify_one(io_service_impl &impl, std::error_code & err) noexcept
        {
            impl.notify_one(err);
        }

    }
}

#endif //LEMON_IO_IO_SERVICE_EPOLL_HPP
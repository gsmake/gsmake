/**
 *
 * @file     io_object_iocp
 * @brief    Copyright (C) 2015  yayanyang All Rights Reserved
 * @author   yayanyang
 * @date     2015/12/07
 */
#ifndef LEMON_IO_OJBJECT_NIO_HPP
#define LEMON_IO_OJBJECT_NIO_HPP
#include <mutex>
#include <cstddef>
#include <functional>

#include <lemon/config.h>
#include <lemon/io/buff.hpp>
#include <lemon/io/irp_base.hpp>
#include <lemon/io/io_object_base.hpp>

namespace lemon {namespace io {

        using io_callback = std::function<void(std::size_t bytes_of_trans, const std::error_code &err) noexcept>;

        struct irp_rw_nio : public irp_base
        {
            io_callback						callback;

            irp_rw_nio(handler owner,io_callback cb,irp_op op):irp_base(owner,op), callback(cb)
            {
                fire = (void(*)(irp_base*))irp_rw_nio::fire_invoke;
                close = (void(*)(irp_base*))irp_rw_nio::release_invoke;
            }

            static void fire_invoke(irp_rw_nio * irp) noexcept
            {
                irp->callback(irp->bytes_of_trans,irp->error_code);
            }

            static void release_invoke(irp_rw_nio * irp) noexcept
            {
                delete irp;
            }
        };



        template<typename Mutex>
        class basic_io_stream : public io_object_base<Mutex>
        {
        public:
            basic_io_stream(basic_io_service<Mutex> & service,handler handle)
                    :io_object_base<Mutex>(service,handle)
            {

            }

            virtual ~basic_io_stream()
            {

            }

            void write(const_buffer buff,io_callback && callback)
            {

            }

            void read(buffer buff, io_callback && callback)
            {

            }
        };

        using io_stream = basic_io_stream<std::mutex>;

    }}

#endif //LEMON_IO_OJBJECT_NIO_HPP
/**
 * 
 * @file     io_object_iocp
 * @brief    Copyright (C) 2015  yayanyang All Rights Reserved 
 * @author   yayanyang
 * @date     2015/12/07
 */
#ifndef LEMON_IO_OJBJECT_IOCP_HPP
#define LEMON_IO_OJBJECT_IOCP_HPP
#include <mutex>
#include <cstddef>
#include <functional>

#include <lemon/config.h>
#include <lemon/io/buff.hpp>
#include <lemon/io/irp_base.hpp>
#include <lemon/io/io_object_base.hpp>

namespace lemon {namespace io {

	using io_callback = std::function<void(std::size_t bytes_of_trans, const std::error_code &err) noexcept>;

	struct irp_rw_iocp : public irp_base
	{
		io_callback						callback;

		irp_rw_iocp(handler owner,io_callback cb,irp_op op):irp_base(owner,op), callback(cb)
		{
			fire = (void(*)(irp_base*))irp_rw_iocp::fire_invoke;
			close = (void(*)(irp_base*))irp_rw_iocp::release_invoke;
		}

		static void fire_invoke(irp_rw_iocp * irp) noexcept
		{
			irp->callback(irp->bytes_of_trans,irp->error_code);
		}

		static void release_invoke(irp_rw_iocp * irp) noexcept
		{
			delete irp;
		}
	};



	template<typename Mutex>
	class basic_io_stream : public io_object_base<Mutex>
	{
	public:
		basic_io_stream(basic_io_service<Mutex> & service,HANDLE handle)
			:io_object_base<Mutex>(service,handle)
		{

		}

		virtual ~basic_io_stream()
		{
			CloseHandle(get());
		}

		void write(const_buffer buff,io_callback && callback)
		{
			auto irp = std::unique_ptr<irp_base>(new irp_rw_iocp(get(),callback,irp_op::write));

			add_irp_write(irp.get());

			DWORD written;

			if (!WriteFile(get(), buff.data, (DWORD)buff.length,&written,(LPOVERLAPPED)irp.get()))
			{
				if (ERROR_IO_PENDING != GetLastError()) {
					std::error_code err;
					irp->error_code = std::error_code(GetLastError(), std::system_category());
					service().post_complete(irp.get(), err);

					if (err)
					{
						remove_irp_write(irp.get());

						throw std::system_error(err);
					}
				}
			}

			irp.release();
		}

		void read(buffer buff, io_callback && callback)
		{
			auto irp = std::unique_ptr<irp_base>(new irp_rw_iocp(get(),callback, irp_op::write));

			add_irp_read(irp.get());

			DWORD read;

			if (!ReadFile(get(), buff.data, (DWORD)buff.length,&read, (LPWSAOVERLAPPED)irp.get()))
			{
				if (ERROR_IO_PENDING != GetLastError()) {
					std::error_code err;
					irp->error_code = std::error_code(GetLastError(), std::system_category());
					service().post_complete(irp.get(), err);

					if (err)
					{
						remove_irp_read(irp.get());

						throw std::system_error(err);
					}
				}
			}

			irp.release();
		}
	};

	using io_stream = basic_io_stream<std::mutex>;

}}

#endif //LEMON_IO_OJBJECT_IOCP_HPP
/**
 * 
 * @file     io_service_iocp
 * @brief    Copyright (C) 2015  yayanyang All Rights Reserved 
 * @author   yayanyang
 * @date     2015/12/07
 */
#ifndef LEMON_IO_IO_SERVICE_IOCP_HPP
#define LEMON_IO_IO_SERVICE_IOCP_HPP
#include <chrono>
#include <system_error>

#include <lemon/config.h>
#include <lemon/nocopy.hpp>
#include <lemon/io/io_errors.hpp>
#include <lemon/io/irp_base.hpp>

namespace lemon { namespace io {

	class io_service_impl : private nocopy
	{
	public:
		io_service_impl()
		{
			_handler = ::CreateIoCompletionPort(INVALID_HANDLE_VALUE, NULL, NULL, 1);

			if(_handler == NULL)
			{
				throw std::system_error(GetLastError(),std::system_category());
			}
		}

		~io_service_impl()
		{
			close();
		}

		void close() noexcept
		{
			if(_handler != NULL)
			{
				CloseHandle(_handler);
				_handler = NULL;
			}
			
		}

		template<typename Duration>
		std::tuple<bool, irp_base*> io_service_dispatch(Duration timeout, std::error_code & err) noexcept
		{
			DWORD bytes;

			ULONG_PTR completionKey;

			irp_base * irp = NULL;

			auto milliseconds = std::chrono::duration_cast<std::chrono::milliseconds>(timeout);

			DWORD timeoutVal = (DWORD)milliseconds.count();

			if(timeout == Duration(-1))
			{
				timeoutVal = INFINITE;
			}

			if (GetQueuedCompletionStatus(_handler, &bytes, &completionKey, (LPOVERLAPPED*)&irp, (DWORD)timeoutVal))
			{
				if(irp != nullptr)
				{
					irp->bytes_of_trans = bytes;
					return std::make_tuple(true, irp);
				}
				else
				{
					return std::tuple<bool, irp_base*>();
				}
				
			}

			DWORD lasterror = GetLastError();

			if (ERROR_ABANDONED_WAIT_0 == lasterror)
			{
				err = make_error_code(errc::io_service_closed);
			}
			else if (WAIT_TIMEOUT != lasterror)
			{
				err = std::error_code(lasterror, std::system_category());

				if (irp == NULL) {
					return std::tuple<bool, irp_base*>();
				}

				irp->error_code = err;

				err.clear();
				
				return std::make_tuple(true, irp);
			}

			err = std::make_error_code(std::errc::timed_out);

			return std::tuple<bool, irp_base*>();

		}

		template<typename Object>
		void io_service_register(Object & obj, std::error_code & err) noexcept
		{
			if (NULL == CreateIoCompletionPort(obj.get(),_handler, 0, 0))
			{
				err = std::error_code(GetLastError(), std::system_category());
			}
		}

		template<typename Object>
		void io_service_unregister(Object &) noexcept
		{

		}

		void io_service_complete(irp_base *irp, std::error_code & err) noexcept
		{
			if(!PostQueuedCompletionStatus(_handler, (DWORD)irp->bytes_of_trans, 0, (LPOVERLAPPED)irp))
			{
				err = std::error_code(GetLastError(), std::system_category());
			}
		}

		void notify_one(std::error_code & err) noexcept
		{
			if (!PostQueuedCompletionStatus(_handler, 0, 0, NULL))
			{
				err = std::error_code(GetLastError(), std::system_category());
			}
		}

	private:

		HANDLE					_handler;
	};

	template<typename Duration>
	inline std::tuple<bool, irp_base*> io_service_dispatch(io_service_impl &impl, Duration timeout, std::error_code & err) noexcept
	{
		return impl.io_service_dispatch(timeout, err);
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
		impl.close();
	}

	inline void io_service_notify_one(io_service_impl &impl, std::error_code & err) noexcept
	{
		impl.notify_one(err);
	}
}}

#endif //LEMON_IO_IO_SERVICE_IOCP_HPP
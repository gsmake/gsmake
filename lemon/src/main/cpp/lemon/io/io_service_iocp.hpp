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
			CloseHandle(_handler);
		}

		template<typename Duration>
		std::tuple<bool, irp_base*> io_service_dispatch(Duration timeout, std::error_code & err) noexcept
		{
			DWORD bytes;

			ULONG_PTR completionKey;

			irp_base * irp = NULL;

			auto milliseconds = std::chrono::duration_cast<std::chrono::milliseconds>(timeout);

			DWORD timeoutVal = milliseconds.count();

			if(timeout.count() == 0)
			{
				timeoutVal = INFINITE;
			}

			if (GetQueuedCompletionStatus(_handler, &bytes, &completionKey, (LPOVERLAPPED*)&irp, (DWORD)timeoutVal))
			{
				return std::make_tuple(true, irp);
			}

			DWORD lasterror = GetLastError();

			if (ERROR_ABANDONED_WAIT_0 != lasterror && WAIT_TIMEOUT != lasterror)
			{
				err = std::error_code(lasterror, std::system_category());

				if (irp == NULL) {
					

					return std::tuple<bool, irp_base*>();
				}
				
				return std::make_tuple(true, irp);
			}

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
		void io_service_unregister(Object & obj) noexcept
		{

		}

	private:

		HANDLE					_handler;
	};

	template<typename Duration>
	std::tuple<bool, irp_base*> io_service_dispatch(io_service_impl &impl, Duration timeout, std::error_code & err) noexcept
	{
		return impl.io_service_dispatch(timeout, err);
	}

	template<typename Object>
	void io_service_register(io_service_impl &impl, Object & obj, std::error_code & err) noexcept
	{
		impl.io_service_register(obj, err);
	}

	template<typename Object>
	void io_service_unregister(io_service_impl &impl, Object & obj) noexcept
	{
		impl.io_service_unregister(obj);
	}
}}

#endif //LEMON_IO_IO_SERVICE_IOCP_HPP
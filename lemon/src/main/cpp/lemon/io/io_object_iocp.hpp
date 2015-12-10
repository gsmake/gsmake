/**
 * 
 * @file     io_object_iocp
 * @brief    Copyright (C) 2015  yayanyang All Rights Reserved 
 * @author   yayanyang
 * @date     2015/12/07
 */
#ifndef LEMON_IO_OJBJECT_IOCP_HPP
#define LEMON_IO_OJBJECT_IOCP_HPP

#include <lemon/config.h>
#include <lemon/io/io_object_base.hpp>

namespace lemon {namespace io {

	template<typename Mutex>
	class io_object_iocp : public io_object_base<Mutex>
	{
	public:
		io_object_iocp(basic_io_service<Mutex> & service,HANDLE handle)
			:io_object_base<Mutex>(service,handle)
		{

		}

		virtual ~io_object_iocp()
		{
			CloseHandle(get());
		}
	};

}}

#endif //LEMON_IO_OJBJECT_IOCP_HPP
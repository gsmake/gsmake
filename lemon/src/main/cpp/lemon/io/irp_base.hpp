/**
 * the io request package base class file
 * @file     irp_base
 * @brief    Copyright (C) 2015  yayanyang All Rights Reserved 
 * @author   yayanyang
 * @date     2015/12/07
 */
#ifndef LEMON_IO_IRP_BASE_HPP
#define LEMON_IO_IRP_BASE_HPP
#include <system_error>
#include <lemon/config.h>
#include <lemon/io/handler.hpp>

namespace lemon { namespace io {


	enum class irp_op {
		read, write
	};

	struct irp_base 
	{
#ifdef WIN32
		OVERLAPPED										overlapped;
#endif //WIN32
		irp_base                                        *next;

		irp_base                                        *prev;

		irp_op                                           op;

		handler											 owner;

		size_t											 bytes_of_trans;

		std::error_code									 error_code;

		void											(*fire)(irp_base* irp);

		void											(*close)(irp_base* irp);

		irp_base(handler owner,irp_op o) :next(nullptr), prev(nullptr), op(o),owner(owner)
		{
#ifdef WIN32
			memset(&overlapped, 0, sizeof(OVERLAPPED));
#endif //WIN32
		}
	};

}}

#endif //LEMON_IO_IRP_BASE_HPP
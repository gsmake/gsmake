/**
 * the io request package base class file
 * @file     irp_base
 * @brief    Copyright (C) 2015  yayanyang All Rights Reserved 
 * @author   yayanyang
 * @date     2015/12/07
 */
#ifndef LEMON_IO_IRP_BASE_HPP
#define LEMON_IO_IRP_BASE_HPP

#include <lemon/config.h>

namespace lemon { namespace io {


	enum class irp_op {
		read, write, accept, connect
	};

	struct irp_base 
#ifdef WIN32
		: OVERLAPPED
#endif //WIN32
	{
		irp_base                                        *next;

		irp_base                                        **prev;

		irp_op                                           op;

		irp_base(irp_op o) :next(nullptr), prev(nullptr), op(o)
		{ }
	};

}}

#endif //LEMON_IO_IRP_BASE_HPP
/**
 * 
 * @file     io_object
 * @brief    Copyright (C) 2015  yayanyang All Rights Reserved 
 * @author   yayanyang
 * @date     2015/12/07
 */
#ifndef LEMON_IO_OBJECT_HPP
#define LEMON_IO_OBJECT_HPP

#include <memory>

#include <lemon/nocopy.hpp>
#include <lemon/io/handler.hpp>
#include <lemon/io/irp_base.hpp>
#include <lemon/io/io_service.hpp>

namespace lemon{ namespace io{

	template<typename Mutex> class basic_io_service;
	
	template<typename Mutex>
	class io_object_base : private nocopy
	{
	public:

		io_object_base(basic_io_service<Mutex> & service,handler h) 
			:_handler(h), _service(service),_readQ(nullptr),_writeQ(nullptr)
		{
			std::error_code err;
			service.io_object_register(*this, err);

			if (err)
			{
				throw std::system_error(err);
			}
		}

		virtual ~io_object_base()
		{
			_service.io_object_unregister(*this);
		}

		bool operator()() const
		{
			return _handler != 0;
		}

		handler get() const
		{
			return _handler;
		}

		void reset(handler val)
		{
			_handler = val;
		}


		void add_irp_read(irp_base * irp) noexcept
		{
			add_irp(&_readQ, irp);
		}

		void remove_irp_read(irp_base *irp) noexcept
		{
			remove_irp(&_readQ, irp);
		}


		void add_irp_write(irp_base * irp) noexcept
		{
			add_irp(&_writeQ, irp);
		}

		void remove_irp_write(irp_base *irp) noexcept
		{
			remove_irp(&_writeQ, irp);
		}

#ifndef WIN32
		void io_process(irp_op op, const std::error_code & err) noexcept
		{

		}
#endif //WIN32

	private:

		static void add_irp(irp_base **header, irp_base *irp) noexcept
		{
			if (*header != nullptr)
			{
				irp->prev = (*header)->prev;
				irp->next = (*header);
				(*header)->prev = &irp->next;
			}
			else
			{
				(*header) = irp;

				irp->next = irp;

				irp->prev = &irp->next;
			}
		}

		static void remove_irp(irp_base **header, irp_base *irp) noexcept
		{
			if (irp == (*header))
			{
				(*header) = nullptr;
			}
			else
			{
				if (irp->next != nullptr)
				{
					irp->next->prev = irp->prev;
				}

				if (irp->prev != nullptr)
				{
					*irp->prev = irp->next;
				}
			}
		}
	private:

		handler	_handler;

		irp_base                                    *_readQ;
		irp_base                                    *_writeQ;

		basic_io_service<Mutex>						&_service;
	};
}}

#endif //LEMON_IO_OBJECT_HPP
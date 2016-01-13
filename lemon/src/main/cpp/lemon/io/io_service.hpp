/**
 * @file     io_service
 * @brief    Copyright (C) 2015  yayanyang All Rights Reserved 
 * @author   yayanyang
 * @date     2015/12/07
 */
#ifndef LEMON_IO_IO_SERVICE_HPP
#define LEMON_IO_IO_SERVICE_HPP

#include <mutex>
#include <tuple>
#include <memory>
#include <system_error>
#include <unordered_map>

#include <lemon/config.h>
#include <lemon/nocopy.hpp>
#include <lemon/io/handler.hpp>
#include <lemon/io/irp_base.hpp>

namespace lemon{ namespace io{
	
	/**
	 *  the io_service_impl forward declaration 
	 */
	class io_service_impl;

#ifndef WIN32
	template<typename Duration>
	std::tuple<bool, handler, irp_op> io_service_poll(io_service_impl &impl, Duration timeout,std::error_code & err) noexcept;
#else
	template<typename Duration>
	std::tuple<bool,irp_base*> io_service_dispatch(io_service_impl &impl, Duration timeout, std::error_code & err) noexcept;
#endif 

	template<typename Object>
	void io_service_register(io_service_impl &impl, Object & obj, std::error_code & err) noexcept;

	template<typename Object>
	void io_service_unregister(io_service_impl &impl, Object & obj) noexcept;

	template<typename Mutex> class io_object_base;

	//
	// The io_service class, all async io method must provide this class object
	//
	template<typename Mutex>
	class basic_io_service 
	{
	public:
		
		basic_io_service():basic_io_service(new io_service_impl())
		{

		}

		basic_io_service(io_service_impl *impl):_impl(impl)
		{

		}

		void io_object_register(io_object_base<Mutex> & obj,std::error_code & err)
		{
			io_service_register(*_impl,obj,err);

			if(!err)
			{
				std::lock_guard<Mutex> lock(_mutex);

				_objects[obj.get()] = &obj;
			}
		}

		void io_object_unregister(io_object_base<Mutex> & obj) noexcept
		{
			io_service_unregister(*_impl, obj);

			std::lock_guard<Mutex> lock(_mutex);

			_objects.erase(obj.get());
		}

		template<typename Duration>
		void dispatch_once(Duration timeout,std::error_code & err)
		{
#ifdef WIN32
			auto result = io_service_dispatch(*_impl, timeout, err);
#else
#endif //WIN32
		}

		template<typename Duration>
		void dispatch_once(Duration timeout)
		{
			std::error_code err;
			dispatch_once(timeout, err);

			if(err)
			{
				throw std::system_error(err);
			}
		}

	private:

		Mutex												_mutex;

		std::unique_ptr<io_service_impl>					_impl;

		std::unordered_map<handler, io_object_base<Mutex>*>	_objects;
	};

	typedef basic_io_service<std::mutex> io_service;
}}

#endif //LEMON_IO_IO_SERVICE_HPP
/**
 * 
 * @file     mutex_none
 * @brief    Copyright (C) 2016  yayanyang All Rights Reserved 
 * @author   yayanyang
 * @date     2016/01/13
 */
#ifndef LEMON_IO_MUTEX_NONE_HPP
#define LEMON_IO_MUTEX_NONE_HPP


namespace lemon{namespace io{
	class mutex_none
	{
	public:
		void lock(){}
		void unlock(){}
	};
}}

#endif //LEMON_IO_MUTEX_NONE_HPP
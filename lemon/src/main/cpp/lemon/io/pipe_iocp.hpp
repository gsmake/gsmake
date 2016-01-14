/**
 * 
 * @file     pipe_iocp
 * @brief    Copyright (C) 2015  yayanyang All Rights Reserved 
 * @author   yayanyang
 * @date     2015/12/07
 */
#ifndef LEMON_IO_PIPE_IOCP_HPP
#define LEMON_IO_PIPE_IOCP_HPP

#include <locale>
#include <memory>

#include <lemon/uuid.hpp>
#include <lemon/config.h>
#include <lemon/io/io_object_iocp.hpp>

namespace lemon {namespace io {
	
	typedef std::wstring_convert<std::codecvt<wchar_t, char, std::mbstate_t>, wchar_t> convert;
	
	template<typename Mutex>
	std::tuple<basic_io_stream<Mutex>*, basic_io_stream<Mutex>*>
		make_pipe(basic_io_service<Mutex> & service, std::error_code & err)
	{
		lemon::uuids::random_generator random;

		std::string name = "\\\\.\\pipe\\lemon-";

		name = name + lemon::uuids::to_string(random());


		SECURITY_ATTRIBUTES sa;

		sa.bInheritHandle = TRUE;

		sa.lpSecurityDescriptor = NULL;

		sa.nLength = sizeof(SECURITY_ATTRIBUTES);

		HANDLE reader, writer;

		convert conv;

		reader = CreateNamedPipeW(
			conv.from_bytes(name).c_str(),
			PIPE_ACCESS_INBOUND | FILE_FLAG_OVERLAPPED,
			PIPE_TYPE_BYTE | PIPE_READMODE_BYTE | PIPE_WAIT,
			PIPE_UNLIMITED_INSTANCES,
			1024,
			1024,
			5000, 
			&sa);   

		if(reader == INVALID_HANDLE_VALUE)
		{
			err = std::error_code(GetLastError(), std::system_category());

			return {};
		}

		writer = CreateFileW(
			conv.from_bytes(name).c_str(),
			GENERIC_WRITE,
			0,
			&sa,
			OPEN_EXISTING,
			FILE_FLAG_OVERLAPPED,
			NULL);

		if (writer == INVALID_HANDLE_VALUE)
		{
			err = std::error_code(GetLastError(), std::system_category());

			return{};
		}

		// exception safe confirm

		std::unique_ptr<basic_io_stream<Mutex>> read_io_object(new basic_io_stream<Mutex>(service, reader));
		std::unique_ptr<basic_io_stream<Mutex>> write_io_object(new basic_io_stream<Mutex>(service, writer));

		return std::make_tuple(read_io_object.release(), write_io_object.release());
	}
}}

#endif //LEMON_IO_PIPE_IOCP_HPP
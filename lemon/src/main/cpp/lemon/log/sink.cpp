#include <ctime>
#include <chrono>
#include <iomanip>
#include <iostream>

#include <lemon/config.h>
#include <lemon/fs/fs.hpp>
#include <lemon/log/sink.hpp>
#include <lemon/log/logger.hpp>



namespace lemon{ namespace log{


	void console::write(const message &msg)
	{
#ifdef WIN32
		switch (msg.LEVEL)
		{
		case level::error:
			SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), FOREGROUND_RED | FOREGROUND_INTENSITY);
			break;
		case level::warn:
			SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), FOREGROUND_BLUE | FOREGROUND_RED | FOREGROUND_INTENSITY);
			break;
		case level::info:
			SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), FOREGROUND_BLUE | FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_INTENSITY);
			break;
		case level::debug:
			SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), FOREGROUND_RED | FOREGROUND_GREEN );
			break;
		case level::trace:
			SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), FOREGROUND_BLUE | FOREGROUND_GREEN );
			break;
		case level::verbose:
			SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), FOREGROUND_GREEN );
			break;
		}
#else
		switch (msg.LEVEL)
		{
		case level::error:
			std::cout << "\e[31m";
			break;
		case level::warn:
			std::cout << "\e[35m";
			break;
		case level::info:
			std::cout << "\e[37m";
			break;
		case level::debug:
			std::cout << "\e[36m";
			break;
		case level::trace:
			std::cout << "\e[32m";
			break;
		case level::verbose:
		default:
			std::cout << "\e[33m";
			break;
		}
#endif 

		std::time_t ts = std::chrono::system_clock::to_time_t(msg.TS);
#ifdef WIN32
		tm t;
		localtime_s(&t,&ts);
		tm *tm = &t;
#else
		auto tm = localtime(&ts);
#endif 


		std::cout << tm->tm_year + 1900 << "-" << tm->tm_mon << "-" << tm->tm_mday << " "

			<< tm->tm_hour << ":" << tm->tm_min << ":" << tm->tm_sec << " "

			<< msg.Source << " (" << fs::filepath(msg.File).filename() << ":" <<  msg.Lines << ") " << msg.Content << std::endl;


#ifdef WIN32
		SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), FOREGROUND_BLUE | FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_INTENSITY);
#endif
	}
}}
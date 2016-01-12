/**
 * 
 * @file     file_sink
 * @brief    Copyright (C) 2016  yayanyang All Rights Reserved 
 * @author   yayanyang
 * @date     2016/01/12
 */
#ifndef LEMON_LOG_FILE_SINK_HPP
#define LEMON_LOG_FILE_SINK_HPP

#include <string>
#include <fstream>
#include <lemon/log/sink.hpp>
#include <lemon/fs/fs.hpp>

namespace lemon{namespace log{

	class file_sink : public sink, private nocopy
	{
	public:
		file_sink(
			const fs::filepath dir,
			const std::string &name,
			const std::string &ext,
			bool time_suffix,
			std::uintmax_t maxisze)
			:_dir(dir),_name(name),_ext(ext)
			,_time_suffix(time_suffix)
			,_maxsize(maxisze),_blocks(0)
		{
			if (!fs::exists(dir))
			{
				fs::create_directories(dir);
			}
		}

		virtual ~file_sink() 
		{
			_stream.close();
		}

			
		void write(const message & msg) final;

	
	private:

		void openfile();

		std::string calc_file_name();

	private:

		const fs::filepath			_dir;
		const std::string			_name;
		const std::string 			_ext;
		bool						_time_suffix;
		std::uintmax_t				_maxsize;
		size_t						_blocks;
		std::ofstream				_stream;
		std::string					_filename;
	};

}}


#endif //LEMON_LOG_FILE_SINK_HPP
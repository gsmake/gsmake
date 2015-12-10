#ifndef LEMON_LOG_FACTORY_HPP
#define LEMON_LOG_FACTORY_HPP

#include <mutex>
#include <atomic>
#include <vector>
#include <string>
#include <thread>

#include <unordered_map>
#include <unordered_set>
#include <condition_variable>

namespace lemon{ namespace log{

	class sink;
	class logger;
	struct message;

	/**
	 * the logger's factory
	 */
	class factory
	{
	public:
		factory();

		void write(const message &msg);

		/**
		 * set the logger's log level
		 * @levels  the log levels
		 * @loggers the target loggers
		 */
		void setlevels(int levels,const std::vector<std::string> &loggers);

		/**
		 * add new logger's sink
		 */
		void add_sink(sink* s);

		/**
		 * remove sink
		 */
		void remove_sink(sink* s);
		/**
		 * get or create new logger
		 */
		const logger& get(const std::string &name);

		/**
		 * close logger factory
		 */
		void close();

	private:

		void writeloop();

	private:
		int													_levels;
		std::mutex          								_mutex;
		std::unordered_map<std::string, logger*>			_loggers;
		std::unordered_set<sink*>							_sinks;
		std::atomic<bool>									_exitflag;
		std::condition_variable_any							_notify;
		std::condition_variable_any							_exit_notify;
		std::thread											_writer;
		std::vector<message>								_messages;
	};

}}

#endif //LEMON_LOG_FACTORY_HPP
#include <lemon/log/sink.hpp>
#include <lemon/log/factory.hpp>
#include <lemon/log/logger.hpp>

namespace lemon{ namespace log{
	factory::factory()
		:_levels((int)level::all),_exitflag(false)
	{
		_writer = std::thread(&factory::writeloop, this);
	}

	void factory::writeloop()
	{
		while(!_exitflag)
		{
			std::unique_lock<std::mutex> lock(_mutex);

			if(_messages.empty())
			{
				if (_exitflag) break; // exit

				_notify.wait(lock);

				continue;
			}

			auto messages = std::move(_messages);

			_messages.clear();

			lock.unlock();

			for(auto& msg : messages)
			{
				for(auto s :_sinks)
				{
					s->write(msg);
				}
			}
		}

		std::unique_lock<std::mutex> lock(_mutex);

		auto messages = std::move(_messages);

		lock.unlock();

		for (auto& msg : messages)
		{
			for (auto s : _sinks)
			{
				s->write(msg);
			}
		}

		_exit_notify.notify_one();
	}

	void factory::write(const message &msg)
	{
		std::lock_guard<std::mutex> lock(_mutex);

		_messages.push_back(msg);

		_notify.notify_one();
	}

	void factory::setlevels(int levels, const std::vector<std::string> &loggers)
	{
		std::lock_guard<std::mutex> lock(_mutex);

		if(loggers.empty())
		{
			_levels = levels;

			return;
		}

		for(auto source: loggers)
		{
			if (_loggers.count(source) == 0)
			{
				auto l = new logger(source, *this);

				l->levels(_levels);

				_loggers[source] = l;
			}
			else
			{
				auto l = _loggers[source];

				l->levels(levels);
			}
		}
	}


	void factory::add_sink(sink* s)
	{
		std::lock_guard<std::mutex> lock(_mutex);

		_sinks.insert(s);
	}

	void factory::remove_sink(sink* s)
	{
		std::lock_guard<std::mutex> lock(_mutex);

		_sinks.erase(s);
	}
	/**
	* get or create new logger
	*/
	const logger& factory::get(const std::string &name)
	{
		std::unique_lock<std::mutex> lock(_mutex);

		if(_loggers.count(name) == 0)
		{
			auto source = new logger(name, *this);

			source->levels(_levels);

			_loggers[name] = source;
		}

		return *_loggers[name];
	}

	/**
	* close logger factory
	*/
	void factory::close()
	{
		std::unique_lock<std::mutex> lock(_mutex);

		if(!_exitflag)
		{
			_exitflag = true;

			_notify.notify_one();

			_exit_notify.wait(lock);
		}
	}
}}
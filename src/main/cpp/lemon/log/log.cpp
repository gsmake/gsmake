#include <lemon/log/log.hpp>
#include <lemon/log/sink.hpp>

namespace lemon{ namespace log{

    namespace {
        std::once_flag flag;

        factory *_factory;
    }

	void init()
	{
		_factory = new factory();
		_factory->add_sink(new console());
	}

    const logger& get(const std::string &name)
    {
        std::call_once(flag,init);

        return _factory->get(name);
    }

    void close()
    {
        std::call_once(flag,init);

		_factory->close();
    }
}}
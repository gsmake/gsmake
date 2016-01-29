#include <lemon/io/io.hpp>
#include <lemon/log/log.hpp>
#include <lemon/test/test.hpp>

using namespace lemon::io;

auto &logger = lemon::log::get("test");

test_(pipe){
	/*io_service_s ioservice;

	pipe_s pipe(ioservice);

	pipe.out().write(cbuff("hello world"), [](size_t , const std::error_code &err) {
		if (err)
		{
			lemonE(logger, "write data err :%s", err.message().c_str());
		}


	});

	char recv_buff[256];

	pipe.in().read(buff(recv_buff), [&](size_t len, const std::error_code &err) {
		if (err)
		{
			lemonE(logger, "write data err :%s", err.message().c_str());
		}
		else
		{
			lemonI(logger, "read data :%s", std::string(recv_buff, recv_buff + len).c_str());
		}
	});

	ioservice.dispatch_once();
	ioservice.dispatch_once();*/
}
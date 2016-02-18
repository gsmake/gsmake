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

test_(socket)
{
	io_service ioservice;

	auto addrinfo = lemon::io::getaddrinfo("", "1812", AF_INET, SOCK_STREAM, AI_PASSIVE)[0];

	socket_server server(ioservice, addrinfo.af(), addrinfo.type(), addrinfo.protocol());

	server.bind(addrinfo.addr());

	server.listen(SOMAXCONN);

	server.accept([](std::unique_ptr<iocp_io_socket> &, address &&, const std::error_code & ec) {
		if (ec)
		{
			lemonE(lemon::log::get("test"), "accept client error :%s", ec.message().c_str());
		}
		else
		{
			lemonI(lemon::log::get("test"), "accept client success");
		}

	});
	
	
	socket_client client(ioservice, AF_INET, SOCK_STREAM, IPPROTO_TCP);

	client.connect(addrinfo.addr(),[](const std::error_code& ec){
		if(ec)
		{
			lemonE(lemon::log::get("test"), "connect service error :%s",ec.message().c_str());
		}
		else
		{
			lemonI(lemon::log::get("test"), "connect success");
		}
	});

	for (;;) 
	{
		ioservice.run_one();
	}
}
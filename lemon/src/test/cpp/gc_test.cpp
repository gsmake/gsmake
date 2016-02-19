#include <lemon/test/test.hpp>
#include <lemon/gc/gc.hpp>
#include <thread>
#include <iostream>

using namespace lemon::gc;

class Test
{
public:
	Test() {}
	Test(int i):_i(i) {}
	Test(char) {}

	~Test()
	{
		std::cout << "~test:" << _i << std::endl;
	}

	void call() const
	{
		std::cout << "call:" << _i << std::endl;
	}

	int _i;
};

test_(gcobject) {

	let<const Test> a = gc_new<Test>(1);

	test_assert(a);

	auto b = gc_new<Test>(2);

	a = std::move(b);

	test_assert(!b);

	ref<const Test> aref = a;

	test_assert(aref.lock());

	a.unlock();

	test_assert(!aref.lock());
}
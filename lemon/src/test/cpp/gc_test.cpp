#include <lemon/test/test.hpp>
#include <lemon/gc/gc.hpp>
#include <string>
#include <unordered_map>
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

	collect_guard collectguard;
		
	let<const Test> a = gc_new<Test>(1);

	test_assert(a);

	auto b = gc_new<Test>(2);

	a = std::move(b);

	test_assert(!b);

	ref<const Test> aref = a;

	test_assert(aref.lock());

	a.unlock();

	collect();

	test_assert(!aref.lock());

	std::unordered_map<std::string, let<const Test>> tests;

	tests["a"] = aref;

	test_assert(!tests["a"]);

	tests["a"] = gc_new<Test>(3);
}
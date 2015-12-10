#include <iostream>
#include <lemon/os/os.hpp>
#include <lemon/test/test.hpp>



using namespace lemon::os;

test_(getenv) {

    auto path = lemon::os::getenv("GSMAKE_HOME");

    test_assert(std::get<1>(path));

    lemonI(lemon::log::get("test"),"%s",std::get<0>(path).c_str());
}

test_(lookup) {
#ifdef WIN32
    auto path = lookup("notepad");
#else
    auto path = lookup("ls");
#endif

    test_assert(std::get<1>(path));

    lemonI(lemon::log::get("test"),"%s",std::get<0>(path).c_str());

}


test_(command) {
    exec("ls").run("-l");
}
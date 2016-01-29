#include <chrono>
#include <iostream>
#include <lemon/test/unit.hpp>
#include <lemon/test/runner.hpp>

namespace lemon{ namespace test{

    unit::unit(const std::string & name, const std::string & filename, int lines)
        :_name(name),_filename(filename),_lines(lines)
    {
        runner::instance().add(this);
    }

    const std::string&unit::name() const
    {
        return _name;
    }

    int unit::lines() const
    {
        return _lines;
    }

    const std::string&unit::file() const
    {
        return _filename;
    }

    T::T(const std::string & name, const std::string & filename, int lines)
        :unit(name,filename,lines)
    {

    }

    void T::run()
    {
        main();
    }

    B::B(const std::string &name, const std::string &filename, int lines)
        :unit(name,filename,lines)
    {

    }

    void B::run()
    {
        // first test

        N = 1;

        using clock = std::chrono::high_resolution_clock;

        namespace chrono = std::chrono;

        auto start  = clock::now();

        main();

        auto duration = chrono::duration_cast<chrono::nanoseconds>(clock::now() - start);

        if (duration > chrono::seconds(1))
        {
            return;
        }

        N = (int)(chrono::duration_cast<chrono::nanoseconds>(chrono::seconds(1)).count() / duration.count());

        start  = clock::now();

        main();

        duration = chrono::duration_cast<chrono::nanoseconds>(clock::now() - start);

        std::cout << "benchmark " << name() << "\t" << duration.count() /  N << " ns/op" << std::endl;
    }
}}
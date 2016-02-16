name "github.com/gsmake/gsmake" -- package name

--version "master" -- package version

plugin "github.com/gsmake/clang"

plugin "github.com/gsmake/lua"



properties.lua = {
    srcDirs = { "lib" };
}

properties.clang = {
    ["lemon"] = {
        type                = "static";
        config              = "config.cmake"; -- the cmake config file
        test_dependencies   = {};
    };

    ["gsmake"] = {
        type            = "exe";
        src             = ""; -- rewrite default srcDirs(src/main/cpp)
        dependencies    = {
            "lemon";
        };
    }
}

name "github.com/lemonkit/lemon" -- package name

--version "master" -- package version

plugin "github.com/gsmake/clang"


clang = {
    ["."] = {
        type                = "static";
        config              = "config.cmake"; -- the cmake config file
        test_dependencies   = {};
    };
}
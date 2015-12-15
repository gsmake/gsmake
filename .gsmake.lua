name "github.com/gsmake/gsmake" -- package name

--version "master" -- package version

plugin "github.com/gsmake/clang"

plugin "github.com/gsmake/lua"



lua = {
    srcDirs = { "lib" };
}

clang = {
    ["lemon"] = {
        type = "static";
    };

    ["gsmake"] = {
        type            = "exe";
        src             = ""; -- rewrite default srcDirs(src/main/cpp)
        dependencies    = {
            "lemon";
            { name  = "github.com/lemonkit/lemon"; module = "lemon" };
        };
    }
}

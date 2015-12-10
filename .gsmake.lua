name "github.com/gsmake/gsmake" -- package name

--version "master" -- package version

plugin "github.com/gsmake/clang"

plugin "github.com/gsmake/lua"



lua = {

    srcDirs = { "lib" };
}

clang = {
    modules = {
        lemoon = {
            type         = "static"         ;
            srcDirs      = { "src/lib/" }   ;
            includeDirs  = { "src/lib"  }   ;
            links        = { "gsmake"   }   ;
        };

        gsmake = {
            type         = "exe";
            srcDirs      = { "src/app"  }   ;
            includeDirs  = { "src/lib"  }   ;
        };

        gsmake_test = {
            alias        = "gsmake-test"    ;
            type         = "exe"            ;
            srcDirs      = { "src/test" }   ;
            includeDirs  = { "src/lib"  }   ;
            links        = { "gsmake"   }   ;
        };
    };
}

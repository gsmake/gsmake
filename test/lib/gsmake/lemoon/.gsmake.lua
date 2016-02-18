name "github.com/lemonkit/lemoon" -- package name

version "develop" -- package version

plugin "github.com/gsmake/lua"

properties.lua = {
    installPrefix   = "lemoon";
    srcDirs         = { "." };
}

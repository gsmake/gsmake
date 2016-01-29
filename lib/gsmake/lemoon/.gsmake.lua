name "github.com/lemonkit/lemoon" -- package name

version "develop" -- package version

plugin "github.com/gsmake/lua"

lua = {
    installPrefix   = "lemoon";
    srcDirs         = { "." };
}

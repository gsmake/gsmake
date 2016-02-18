return {
    PackageFileName         =  ".gsmake.lua";
    ConfigFileName          =  ".gsmakeconfig.lua";
    TempDirName             =  ".gsmake";
    DefaultVersion          =  "snapshot";
    SkipDirs                = { ".gsmake",".git", ".svn" };
    TargetHost              = require "lemoon.sys" .host();
    TargetArch              = require "lemoon.sys" .arch();
    Host                    = require "lemoon.sys" .host();
    Arch                    = require "lemoon.sys" .arch();
}

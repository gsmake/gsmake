local class     = require "lemoon.class"
local logger    = class.new("lemoon.log","lake")

local cmake = nil

task.cmakegen = function(self)
    cmake = class.new("cmake",self)

    cmake:cmakegen()
end
task.cmakegen.Desc = "generate cmake build files"


task.compile = function(self)
    cmake:compile()
end
task.compile.Desc = "clang package compile task"
task.compile.Prev = "cmakegen"

task.install = function(self,install_path)
    cmake:install(install_path)
end
task.install.Desc = "clang package install package"
task.install.Prev = "compile"

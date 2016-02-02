local class     = require "lemoon.class"
local logger    = class.new("lemoon.log","gsmake")

local cmake = nil

task.resources = function(self)
    
    cmake = class.new("cmake",self)

    return cmake:cmakegen()
end
task.resources.Desc = "generate cmake build files"


task.compile = function(self)
    return cmake:compile()
end
task.compile.Desc = "clang package compile task"
task.compile.Prev = "resources"

task.install = function(self,install_path)
    return cmake:install(install_path)
end
task.install.Desc = "clang package install package"
task.install.Prev = "compile"

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
    -- local cmake_build_dir = get_cmake_build_dir(self)
    -- local exec = sys.exec(cmake_path)
    -- exec:dir(cmake_build_dir)
    -- exec:start("--build",".")
    -- exec:wait()
end
task.install.Desc = "clang package install package"
task.install.Prev = "compile"

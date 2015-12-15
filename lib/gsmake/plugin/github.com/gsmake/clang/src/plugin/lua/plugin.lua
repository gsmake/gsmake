local class     = require "lemoon.class"

task.cmakegen = function(self)
    class.new("cmakegen",self):run()
end
task.cmakegen.Desc = "generate cmake build files"


task.compile = function(self)

end
task.compile.Desc = "clang package compile task"
task.compile.Prev = "cmakegen"

task.install = function(self,install_path)

end
task.install.Desc = "clang package install package"
task.install.Prev = "compile"

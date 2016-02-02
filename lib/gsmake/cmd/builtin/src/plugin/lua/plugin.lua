local class     = require "lemoon.class"
local filepath  = require "lemoon.filepath"
local console   = class.new("lemoon.log","console")

task.list = function(self)
    local tasks = self.Owner.ValidTasks

    for name,taskgroup in pairs(tasks) do
        console:I("task %s :",name)
        for _,task in ipairs(taskgroup or {}) do
            console:I("\t%s\n\t\tfrom package [%s:%s]",task.Desc,task.Package.Name,task.Package.Version)
        end
    end
end
task.list.Desc = "list all task"


task.cache = function(self,cmd,path)
end

task.cache.Desc = "cache local package"

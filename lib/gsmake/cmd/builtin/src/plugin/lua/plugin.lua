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

    if cmd == "list" then
        lake.DB:list_cached(function(name,path,version)
            console:I("\t[%s:%s] %s",name,version,path)
        end)
        return 
    end

    path = filepath.abs(path)

    local lake = class.new("lake",path)

    if lake.Config.GSMAKE_WORKSPACE ~= path then
        console:E("local path is not a gsmake package :%s",path)
        return true
    end

    local package = lake.Loader:load(lake.Config.GSMAKE_WORKSPACE)

    if cmd == "add" then
        lake.DB:cached_source(package.Name,package.Version,path,path)
    elseif cmd == "rm" then
        lake.DB:remove_source(package.Name,package.Version,path,path)
    end
end

task.cache.Desc = "cache local package"

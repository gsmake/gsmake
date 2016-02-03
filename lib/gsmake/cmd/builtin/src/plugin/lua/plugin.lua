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

    local gsmake = self.Owner.Loader.GSMake
    local repo = gsmake.Repo

    if cmd == "list" then -- list the cached packages
        repo:query_cached_sources(function(name,path,version)
            console:I("\t[%s:%s] %s",name,version,path)
        end)
        return
    end

    path = filepath.abs(path)

    local package = class.new("gsmake.loader",gsmake,path).Package

    if package.External then
        throw("target path is not a valid gsmake package :%s",path)
    end

    if cmd == "add" then
        repo:save_cached_source(package.Name,package.Version,package.Path)
    elseif cmd == "rm" then
        repo:remove_cached_source(package.Name,package.Version,package.Path)
    else
        console:E("unknown cache command option :%s",cmd)
        return true
    end

end

task.cache.Desc = "cache local package"

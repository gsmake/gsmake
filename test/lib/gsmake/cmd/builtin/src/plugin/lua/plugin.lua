local class     = require "lemoon.class"
local filepath  = require "lemoon.filepath"
local console   = class.new("lemoon.log","console")

task.list = function(self)
    local tasks = self.Owner.ValidTasks

    for name,taskgroup in pairs(tasks) do
        print(string.format("task %s :",name))
        for _,task in ipairs(taskgroup or {}) do
            print(string.format("\t%s\n\t\tfrom package [%s:%s]",task.Desc,task.Package.Name,task.Package.Version))
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

    if not path then
        console:E("expect caching package path")
        return true
    end

    path = filepath.abs(path)

    local package = class.new("gsmake.loader",gsmake,path).Package

    if package.External then
        throw("target path is not a valid gsmake package :%s",path)
    end

    if cmd == "add" then
        console:I("cache package [%s:%s] ...",package.Name,package.Version)
        repo:save_cached_source(package.Name,package.Version,package.Path)
        console:I("cache package [%s:%s] -- success",package.Name,package.Version)
    elseif cmd == "rm" then
        console:I("remove cached package [%s:%s] ...",package.Name,package.Version)
        repo:remove_cached_source(package.Name,package.Version,package.Path)
        console:I("remove cached package [%s:%s] -- success",package.Name,package.Version)
    else
        console:E("unknown cache command option :%s",cmd)
        return true
    end

end

task.cache.Desc = "cache local package"

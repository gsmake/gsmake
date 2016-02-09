local fs        = require "lemoon.fs"
local sys       = require "lemoon.sys"
local uuid      = require "lemoon.uuid"
local class     = require "lemoon.class"
local filepath  = require "lemoon.filepath"
local throw     = require "lemoon.throw"
local logger    = class.new("lemoon.log","gsmake")
local console   = class.new("lemoon.log","console")


task.sync_init = function(self)
    local ok,path = sys.lookup("git")

    if not ok then
        throw("git tool not found. you need manual install it :https://git-scm.com/ ")
    end

    gitpath = path
end

task.sync_remote = function(self,name,version,remote)
    local workdir = filepath.join(loader.Config.GlobalRepo,"git",name)
    if not fs.exists(workdir) then
        fs.mkdir(workdir,true)
    end

    local target = filepath.join(workdir,"mirror")

    if not fs.exists(target) then
        local tmpname = uuid.gen()

        local exec = sys.exec(gitpath)

        local tmppath = filepath.join(sys.tmpdir(),tmpname)

        logger:D("git sync:\n\tsource :%s\n\ttarget: %s",remote,tmppath)

        exec:dir(sys.tmpdir())
        exec:start("clone","--mirror",remote,tmpname)

        if exec:wait() ~= 0 then
            throw("clone git repo from %s -- failed",remote)
        end

        logger:D("git sync:\n\tsource :%s\n\ttarget: %s",tmppath,target)

        if fs.exists(target) then
            fs.rm(target,true)
        end

        exec:dir(workdir)
        exec:start("clone","--mirror",tmppath,"mirror")

        if exec:wait() ~= 0 then
            throw("clone git repo from %s -- failed",tmppath)
        end
    end

    local sourceTarget = filepath.join(workdir,version)

    if fs.exists(sourceTarget) then
        fs.rm(sourceTarget,true)
    end

    local exec = sys.exec(gitpath)

    exec:dir(workdir)
    exec:start("clone",target,version)

    if exec:wait() ~= 0 then
        throw("clone git repo from %s -- failed",target)
    end

    local gitversion = version

    if gitversion == loader.Config.DefaultVersion then
        gitversion = "master"
    end

    exec:dir(sourceTarget)
    exec:start("checkout",gitversion)

    if exec:wait() ~= 0 then
        throw("git repo(%s) checkout %s -- failed",sourceTarget,gitversion)
    end

    local repo = loader.GSMake.Repo

    repo:save_sync(name,version,remote,target,"git")

    repo:save_source(name,version,target,sourceTarget)
end
task.sync_remote.Desc = "git downloader#sync_remote"
task.sync_remote.Prev = "sync_init"


task.sync_source = function(self,install_path)

end
task.sync_source.Desc = "git downloader#sync_source"
task.sync_source.Prev = "sync_init"

local fs = require "lemoon.fs"
local url = require "lemoon.url"
local sys = require "lemoon.sys"
local uuid = require "lemoon.uuid"
local class = require "lemoon.class"
local filepath = require "lemoon.filepath"

-- cached logger
local logger = class.new("lemoon.log","lake")

local module = {}
function module.ctor(lake,name,version)

    local ok,path = sys.lookup("git")

    if not ok then
        error("git tool not found. you need manual install it :https://git-scm.com/ ")
    end

    logger:D("found git tool :'%s'",path)

    local obj = {
        lake        = lake;
        name        = name;
        version     = version;
        exe         = path;
        db          = lake.DB;
    }

    return obj
end


function module:sync_source()
    return self.db:query_source(self.name,self.version)
end

function module:sync_remote(remote)

    local workdir = filepath.join(self.lake.Config.GSMAKE_REPO,"git",self.name)

    if not fs.exists(workdir) then

        fs.mkdir(workdir,true)
    end

    logger:I("workdir :%s",workdir)

    local repo = filepath.base(url.parse(remote).path):gsub("%.git","")

    local target = filepath.join(workdir,repo)

    logger:I("git sync target path :%s",target)

    if not fs.exists(target) then

        local tmpname = uuid.gen()

        local exec = sys.exec(self.exe)

        local tmppath = filepath.join(sys.tmpdir(),tmpname)

        logger:D("git sync:\n\tsource :%s\n\ttarget: %s",remote,tmppath)

        exec:dir(sys.tmpdir())
        exec:start("clone","--mirror",remote,tmpname)

        if exec:wait() ~= 0 then
            error(string.format("clone git repo from %s -- failed",remote))
        end

        logger:D("git sync:\n\tsource :%s\n\ttarget: %s",tmppath,target)

        if fs.exists(target) then
            fs.rm(target,true)
        end

        local exec = sys.exec(self.exe)

        exec:dir(workdir)
        exec:start("clone","--mirror",tmppath,repo)

        if exec:wait() ~= 0 then
            error(string.format("clone git repo from %s -- failed",tmppath))
        end

    end

    -- checkout version

    local sourceTarget = filepath.join(workdir,self.version)

    if fs.exists(sourceTarget) then
        fs.rm(sourceTarget,true)
    end

    local exec = sys.exec(self.exe)

    exec:dir(workdir)
    exec:start("clone",target,self.version)

    if exec:wait() ~= 0 then
        error(string.format("clone git repo from %s -- failed",target))
    end

    local version = self.version

    if version == self.lake.Config.GSMAKE_DEFAULT_VERSION then
        version = "master"
    end

    local exec = sys.exec(self.exe)
    exec:dir(sourceTarget)
    exec:start("checkout",version)

    if exec:wait() ~= 0 then
        error(string.format("git repo(%s) checkout %s -- failed",sourceTarget,version))
    end

    self.db:save_sync(self.name,self.version,remote,target,"git")

    self.db:save_source(self.name,self.version,target,sourceTarget)

end

return module

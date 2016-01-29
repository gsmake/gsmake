local fs = require "lemoon.fs"
local url = require "lemoon.url"
local sys = require "lemoon.sys"
local uuid = require "lemoon.uuid"
local class = require "lemoon.class"
local throw = require "lemoon.throw"
local filepath = require "lemoon.filepath"

-- cached logger
local logger = class.new("lemoon.log","gsmake")
local console = class.new("lemoon.log","console")

local module = {}
function module.ctor(lake,name,version)

    local ok,path = sys.lookup("git")

    if not ok then
        throw("git tool not found. you need manual install it :https://git-scm.com/ ")
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

    console:I("clone package [%s:%s] from %s",self.name,self.version,remote)

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

        local exec = sys.exec(self.exe,function(msg)
            logger:I("%s",msg)
        end)

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
        exec:start("clone","--mirror",tmppath,repo)

        if exec:wait() ~= 0 then
            throw("clone git repo from %s -- failed",tmppath)
        end

    end

    -- checkout version

    local sourceTarget = filepath.join(workdir,self.version)

    if fs.exists(sourceTarget) then
        fs.rm(sourceTarget,true)
    end

    local exec = sys.exec(self.exe,function(msg)
        logger:I("%s",msg)
    end)

    exec:dir(workdir)
    exec:start("clone",target,self.version)

    if exec:wait() ~= 0 then
        throw("clone git repo from %s -- failed",target)
    end

    local version = self.version

    if version == self.lake.Config.GSMAKE_DEFAULT_VERSION then
        version = "master"
    end

    exec:dir(sourceTarget)
    exec:start("checkout",version)

    if exec:wait() ~= 0 then
        throw("git repo(%s) checkout %s -- failed",sourceTarget,version)
    end

    self.db:save_sync(self.name,self.version,remote,target,"git")

    self.db:save_source(self.name,self.version,target,sourceTarget)

    console:I("clone package [%s:%s] from %s -- success",self.name,self.version,remote)

end

return module

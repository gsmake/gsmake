local fs        = require "lemoon.fs"
local class     = require "lemoon.class"
local filepath  = require "lemoon.filepath"


local logger    = class.new("lemoon.log","gsmake")
local logsink    = require "lemoon.logsink"

local module = {}

local once_flag = false

function module.ctor(workspace)

    local obj = {
        Config  = class.clone(require "config");
        Remotes = class.clone(require "remotes");
    }


    -- query the gsmake home path
    obj.Config.GSMAKE_HOME             = os.getenv(obj.Config.GSMAKE_ENV)
    -- set the machine scope package cached directory
    obj.Config.GSMAKE_REPO             = filepath.join(obj.Config.GSMAKE_HOME,"repo")
    -- set the project workspace
    obj.Config.GSMAKE_WORKSPACE        = workspace

    if not fs.exists(filepath.join(obj.Config.GSMAKE_WORKSPACE ,obj.Config.GSMAKE_FILE)) then
        obj.Config.GSMAKE_WORKSPACE = obj.Config.GSMAKE_HOME
    end

    -- set the project depend packages install path
    obj.Config.GSMAKE_INSTALL_PATH     = filepath.join(obj.Config.GSMAKE_WORKSPACE,obj.Config.GSMAKE_TMP_DIR)

    -- init file sink

    if not once_flag then
        local name = "gsmake" .. os.date("-%Y-%m-%d-%H_%M_%S")
        logsink.file_sink(
            "gsmake",
            filepath.join(obj.Config.GSMAKE_INSTALL_PATH,"log"),
            name,
            ".log",
            false,
            1024*1024*10)

        logsink.console_sink("console")

        once_flag = true
    end

    if not fs.exists(obj.Config.GSMAKE_REPO) then
        fs.mkdir(obj.Config.GSMAKE_REPO,true) -- create repo directories
    end

    if not fs.exists(obj.Config.GSMAKE_INSTALL_PATH) then
        fs.mkdir(obj.Config.GSMAKE_INSTALL_PATH,true) -- create repo directories
    end


    logger:D("gsmake variables :")

    for k,v in pairs(obj.Config) do
        local k = string.format("var %s = ",k)

        local len = 30

        if #k < len then
            k = string.format("%s%s",k,string.rep(" ",len - #k))
        end

        logger:D("%s = '%s'",k,v)
    end


    return obj

end

function module:loadSystemPlugin(dir)

    if fs.exists(filepath.join(dir,self.Config.GSMAKE_FILE)) then
        local package = self.Loader:load(dir)
        self.DB:save_source(package.Name,package.Version,dir,dir,true)
        return
    end

    fs.list(dir,function(entry)
        if entry == "." or entry == ".." then return end

        local path = filepath.join(dir,entry)

        if fs.isdir(path) then
            self:loadSystemPlugin(path)
        end
    end)

end

function module:run(...)
    self.DB     = class.new("lake.db",self)
    self.Sync   = class.new("lake.sync",self)
    self.Loader = class.new("lake.loader",self)
    -- load default plugins

    local pluginDir = filepath.join(self.Config.GSMAKE_HOME,"lib/gsmake/plugin")

    self:loadSystemPlugin(pluginDir)

    -- load root package
    local package = self.Loader:load(self.Config.GSMAKE_WORKSPACE)

    class.new("lake.runner",package):run(...)
end

return module

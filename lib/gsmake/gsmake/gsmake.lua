local fs        = require "lemoon.fs"
local host      = require "gsmake.host"
local arch      = require "gsmake.arch"
local class     = require "lemoon.class"
local throw     = require "lemoon.throw"
local filepath  = require "lemoon.filepath"
local logsink   = require "lemoon.logsink"
local logger    = class.new("lemoon.log","gsmake")
local console   = class.new("lemoon.log","console")


local module = {}

local openlog = function(gsmake)

    local name = "gsmake" .. os.date("-%Y-%m-%d-%H_%M_%S")

    local path = filepath.join(gsmake.Config.Workspace,gsmake.Config.TempDirName,"log")

    if not fs.exists(path) then
        fs.mkdir(path,true)
    end

    logsink.file_sink(
        "gsmake",
        path,
        name,
        ".log",
        false,
        1024*1024*10)
end


local options = {

    ["^-host"] = function (gsmake,val)
        if not host[val] then
            console:W("TargetHost(%s) not changed : unsupport host %s",gsmake.Config.TargetHost,val)
            return
        end

        gsmake.Config.TargetHost = val
    end;

    ["^-arch"] = function (gsmake,val)
        if not arch[val] then
            console:W("TargetArch(%s) not changed : unsupport arch %s",gsmake.Config.TargetArch,val)
            return
        end

        gsmake.Config.TargetArch = val
    end;
}


local function parseoptions (gsmake,args)

    local skip = false

    for i,arg in ipairs(args) do
        if not skip then
            local stop = true
            for option,call in pairs(options) do
                if arg:match(option) then
                    local val = arg:sub(#option)
                    if not val or val == "" then
                        val = args[i + 1]
                        skip = true
                    end

                    if not val  or val == ""  then
                        throw("expect option(%s)'s val ",option:sub(2))
                    end
                    call(gsmake,val)
                    stop = false
                    break
                end
            end

            if stop then
                return table.pack(table.unpack(args,i))
            end
        else
            skip = false
        end
    end

    return {}
end

-- create new gsmake runtimes
-- @arg workspace gsmake workspace
function module.ctor(workspace,env,args)

    local gsmake = {
        Config      = class.clone(require "config")     ; -- global config table
        Remotes     = class.clone(require "remotes")    ; -- remote lists
        Loaders     = {}                                ; -- package loader's table
    }

    gsmake.args                 = parseoptions(gsmake,args)

    -- set the gsmake home path
    gsmake.Config.Home          = os.getenv(env)
    -- set the machine scope package cached directory
    gsmake.Config.GlobalRepo    = gsmake.Config.GlobalRepo or filepath.join(gsmake.Config.Home,".repo")
    -- set the project workspace
    gsmake.Config.Workspace     = workspace

    if not fs.exists(filepath.join(workspace ,gsmake.Config.PackageFileName)) then
        gsmake.Config.Workspace = gsmake.Config.Home
    end

    openlog(gsmake)

    if not fs.exists(gsmake.Config.GlobalRepo) then
        fs.mkdir(gsmake.Config.GlobalRepo,true) -- create repo directories
    end

    gsmake.Repo = class.new("gsmake.repo",gsmake,gsmake.Config.GlobalRepo)

    -- cache builtin plugins
    module.load_system_plugins(gsmake,filepath.join(gsmake.Config.Home,"lib/gsmake/plugin"))

    -- create root package loader
    local loader = class.new("gsmake.loader",gsmake,gsmake.Config.Workspace)

    gsmake.Loaders[string.format("%s:%s",loader.Package.Name,loader.Package.Version)] = loader

    gsmake.Package = loader.Package

    -- load builtin system commands
    module.load_system_commands(gsmake,gsmake.Package,filepath.join(gsmake.Config.Home,"lib/gsmake/cmd"))

    -- load builtin system downloaders
    module.load_system_downloaders(gsmake,filepath.join(gsmake.Config.Home,"lib/gsmake/sync"))


    loader:load()
    loader:setup()

    console:I("gsmake target host %s",gsmake.Config.TargetHost)
    console:I("gsmake target arch %s",gsmake.Config.TargetArch)

    return gsmake
end

function module:load_system_downloaders(dir)

    if fs.exists(filepath.join(dir,self.Config.PackageFileName)) then
        local loader = class.new("gsmake.loader",self,dir)
        local package = loader:load()
        self.Repo:save_source(package.Name,package.Version,dir,dir,true)
        return
    end

    fs.list(dir,function(entry)
        if entry == "." or entry == ".." then return end

        local path = filepath.join(dir,entry)

        if fs.isdir(path) then
            module.load_system_downloaders(self,path)
        end
    end)
end

function module:load_system_commands(rootPackage,dir)
    if fs.exists(filepath.join(dir,self.Config.PackageFileName)) then
        local package = class.new("gsmake.loader",self,dir).Package
        self.Repo:save_source(package.Name,package.Version,dir,dir,true)
        local plugin = class.new("gsmake.plugin",package.Name,rootPackage)
        rootPackage.Plugins[package.Name] = plugin
        return
    end

    fs.list(dir,function(entry)
        if entry == "." or entry == ".." then return end

        local path = filepath.join(dir,entry)

        if fs.isdir(path) then
            module.load_system_commands(self,rootPackage,path)
        end
    end)
end

function module:load_system_plugins(dir)
    if fs.exists(filepath.join(dir,self.Config.PackageFileName)) then
        local package = class.new("gsmake.loader",self,dir).Package
        self.Repo:save_source(package.Name,package.Version,dir,dir,true)
        return
    end

    fs.list(dir,function(entry)
        if entry == "." or entry == ".." then return end

        local path = filepath.join(dir,entry)

        if fs.isdir(path) then
            module.load_system_plugins(self,path)
        end
    end)
end

function module:run ()
    return self.Package.Loader:run(table.unpack(self.args))
end

return module

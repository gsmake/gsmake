-- the gsmake package module
local fs        = require "lemoon.fs"
local class     = require "lemoon.class"
local filepath  = require "lemoon.filepath"

-- cached logger
local logger = class.new("lemoon.log","gsmake")
local console   = class.new("lemoon.log","console")

local module = {}

function module.ctor(lake,path,name,version)
    assert(fs.exists(path),"package path not exists")

    local obj =
    {
        lake        = lake                                           ;
        Lake        = lake                                           ;
        db          = lake.DB                                        ;
        Path        = path                                           ;
        Plugins     = {}                                             ; -- package scope register plugins
        Tasks       = {}                                             ; -- package scope register tasks
        Properties  = {}                                             ; -- package scrope properties
    }

    local gsmakeFilePath = filepath.join(path,lake.Config.GSMAKE_FILE)

    if fs.exists(gsmakeFilePath) then
        logger:I("load gsmake standard package ...\n\tdir :%s",path)

        local sandbox = class.new("lemoon.sandbox","lake.sandbox.package",obj)

        sandbox:run(gsmakeFilePath)
    else
        logger:I("load gsmake external package ...\n\tdir :%s",path)
    end

    if obj.Name == nil then
        obj.Name = name
    end

    if obj.Version == nil then
        obj.Version = version or  lake.Config.GSMAKE_DEFAULT_VERSION ;
    end

    logger:I("load gsmake package [%s:%s] -- success\n\tdir :%s",obj.Name,obj.Version,path)

    return obj
end

function module:link()

    logger:D("link package [%s:%s] ... \n\tdir :%s",self.Name,self.Version,self.Path)

    for _,plugin in pairs(self.Plugins) do
        -- install dependency plugin
        logger:D("[%s:%s] load and link plugin [%s:%s]",self.Name,self.Version,plugin.Name,plugin.Version)

        local package = plugin:load()

        package:link()

        logger:D("[%s:%s] load and link plugin [%s:%s] -- success",self.Name,self.Version,plugin.Name,plugin.Version)
    end


    logger:I("link package [%s:%s] -- success \n\tdir :%s",self.Name,self.Version,self.Path)
end

function module:setup()

    logger:D("setup package [%s:%s] ... \n\tdir :%s",self.Name,self.Version,self.Path)

    for _,plugin in pairs(self.Plugins) do

        local package = plugin.Package

        logger:D(
            "[%s:%s] setup plugin [%s:%s] ...\n\tdir :%s",
            self.Name,self.Version,plugin.Name,plugin.Version,package.Path)

        local ok = self.db:query_install(package.Name,package.Version)

        if not ok or not fs.isdir(plugin.Path) then -- link plugin

            logger:D(
                "[%s:%s] install plugin [%s:%s] ...\n\tinstall dir :%s",
                self.Name,self.Version,plugin.Name,plugin.Version,plugin.InstallDir)

            class.new("lake",package.Path):run("install",plugin.InstallDir)

            self.db:save_install(package.Name,package.Version,package.Path,plugin.Path,true)

            logger:D(
                "[%s:%s] install plugin [%s:%s] -- success\n\tinstall dir :%s",
                self.Name,self.Version,plugin.Name,plugin.Version,plugin.InstallDir)

        end

        plugin:setup()

        logger:D(
            "[%s:%s] setup plugin [%s:%s] -- success\n\tdir :%s",
            self.Name,self.Version,plugin.Name,plugin.Version,package.Path)
    end

    logger:D("setup package [%s:%s] ... \n\tdir :%s",self.Name,self.Version,self.Path)
end


return module

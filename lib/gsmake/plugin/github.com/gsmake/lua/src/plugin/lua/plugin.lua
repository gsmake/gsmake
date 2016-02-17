local fs        = require "lemoon.fs"
local throw     = require "lemoon.throw"
local class     = require "lemoon.class"
local filepath  = require "lemoon.filepath"
local logger    = class.new("lemoon.log","gsmake")

local config = {

    skipDirs        = loader.Config.SkipDirs;
    srcDirs         = { "src/main/lua" };
    pluginSrcDirs   = { "src/plugin/lua" };
}

local dependencies_dir = nil

task.resources = function(self)

    local properties        = self.Owner.Properties
    local dependencies      = nil

    if properties.lua ~= nil then
        dependencies = properties.lua.dependencies
    end

    dependencies_dir = filepath.toslash(filepath.join(loader.Temp,"lua"))

    if dependencies ~= nil then
        if type(dependencies) == "function" then
            dependencies = dependencies()
        end

        local gsmake = self.Owner.Loader.GSMake

        for _,dep in ipairs(dependencies) do
            if dep.version == nil then
                dep.version = loader.Config.DefaultVersion
            end

            local sourcePath = loader.Sync:sync(dep.name,dep.version)
            -- load the package
            local packageloader = class.new("gsmake.loader",self.Owner.Loader.GSMake,sourcePath,dep.name,dep.version)
            -- link the source package
            packageloader:load()
            -- setup package
            packageloader:setup()

            if packageloader:run("install",dependencies_dir) then
                return true
            end
        end
    end
end

task.resources.Desc = "prepare lua project's resources"


task.install = function(self,install_path)

    if install_path == nil or install_path == "" then
        throw("task install expect install path")
    end

    install_path = fs.abs(install_path)

    local packagePath       = self.Owner.Path
    local properties        = self.Owner.Properties
    local name              = self.Owner.Name

    local pluginSrcDirs     = config.pluginSrcDirs
    local srcDirs           = config.srcDirs
    local skipDirs          = config.skipDirs
    local prefix            = ""

    if properties.lua ~= nil then
        if properties.lua.pluginSrcDirs ~= nil then
            pluginSrcDirs = properties.lua.pluginSrcDirs
        end

        if properties.lua.srcDirs ~= nil then
            srcDirs = properties.lua.srcDirs
        end

        if properties.lua.installPrefix ~= nil then
            prefix = properties.lua.installPrefix
        end

        for _,v in ipairs(properties.lua.skipDirs or {}) do
            table.insert(skipDirs,v)
        end
    end

    local targetPath  =  filepath.join(install_path,"gsmake")

    for _,dir in pairs(pluginSrcDirs) do
        local srcDir = filepath.join(packagePath,dir)

        if fs.exists(srcDir) then
            fs.copy_dir(srcDir,targetPath,fs.update_existing)
        end
    end

    -- remove preversion lua library
    targetPath = filepath.join(install_path,"lib",prefix)

    for _,dir in pairs(srcDirs) do
        local srcDir = filepath.join(packagePath,dir)

        if fs.exists(srcDir) then
            fs.copy_dir(srcDir,targetPath,fs.update_existing)
        end
    end

    local deps = filepath.join(dependencies_dir,"lib")

    if fs.exists(deps) then
        fs.copy_dir(filepath.join(deps,entry),targetPath,fs.update_existing)
    end
end

task.install.Desc = "lua language install task"
task.install.Prev = "resources"

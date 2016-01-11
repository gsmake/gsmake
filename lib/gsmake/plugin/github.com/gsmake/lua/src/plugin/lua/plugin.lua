local fs        = require "lemoon.fs"
local class     = require "lemoon.class"
local filepath  = require "lemoon.filepath"
local logger    = class.new("lemoon.log","lake")

local config = {

    skipDirs        = lake.Config.GSMAKE_SKIP_DIRS;
    srcDirs         = { "src/main/lua" };
    pluginSrcDirs   = { "src/plugin/lua" };
}



task.install = function(self,prefix)

    if prefix == nil or prefix == "" then
        error("task install expect install path")
    end

    prefix = fs.abs(prefix)

    local packagePath       = self.Owner.Path
    local properties        = self.Owner.Properties
    local name              = self.Owner.Name

    local pluginSrcDirs     = config.pluginSrcDirs
    local srcDirs           = config.srcDirs
    local skipDirs          = config.skipDirs

    if properties.lua ~= nil then
        if properties.lua.pluginSrcDirs ~= nil then
            pluginSrcDirs = properties.lua.pluginSrcDirs
        end

        if properties.lua.srcDirs ~= nil then
            srcDirs = properties.lua.srcDirs
        end

        for _,v in ipairs(properties.lua.skipDirs or {}) do
            table.insert(skipDirs,v)
        end
    end

    local targetPath  =  filepath.join(prefix,"gsmake",name)

    for _,dir in pairs(pluginSrcDirs) do
        local srcDir = filepath.join(packagePath,dir)

        if fs.exists(srcDir) then
            fs.copy_dir(srcDir,targetPath,"fm")
        end
    end

    -- remove preversion lua library
    targetPath = filepath.join(prefix,"lib")

    for _,dir in pairs(srcDirs) do
        local srcDir = filepath.join(packagePath,dir)

        if fs.exists(srcDir) then
            fs.copy_dir(srcDir,targetPath,"fm")
        end
    end
end

task.install.Desc = "lua language install task"

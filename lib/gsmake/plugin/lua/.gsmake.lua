name "github.com/gsmake/lua" -- package name

local fs        = require "lemoon.fs"
local class     = require "lemoon.class"
local filepath  = require "lemoon.filepath"
local logger    = class.new("lemoon.log","lake")

task.install = function(self,prefix)

    local packagePath   = self.Package.Path
    local properties    = self.Package.Properties
    local name          = self.Owner.Name

    local subdir = name:gsub("%.","/")

    local targetPath  =  filepath.join(prefix,"gsmake",subdir,"lib",subdir)

    -- remove preversion plugin
    if fs.exists(targetPath) then
        fs.rm(targetPath,true)
    end

    for _,dir in pairs(properties.lua.pluginSrcDirs) do
        local srcDir = filepath.join(packagePath,dir)

        if fs.exists(srcDir) then
            fs.copy_dir_and_children(srcDir,targetPath,properties.lua.skipDirs)
        end
    end

end

task.install.Desc = "clang bootstrap install task"

lua = {

    skipDirs        = { ".gsmake",".git" };

    pluginSrcDirs   = { "src/plugin/lua" };
}

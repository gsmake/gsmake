name "github.com/gsmake/lua"

local fs        = require "lemoon.fs"
local class     = require "lemoon.class"
local filepath  = require "lemoon.filepath"
local logger    = class.new("lemoon.log","lake")

-- define the boost install task
task.install = function(self,install_path)
	-- plugin install prefix is package's name
	local packagePath   = self.Package.Path
    local name          = self.Owner.Name

	logger:I("install path :%s",install_path)

	local targetPath  =  filepath.join(install_path,"gsmake",name)

	local srcDir = filepath.join(packagePath,"src/plugin/lua")

	if fs.exists(srcDir) then
		logger:V("copy\n\tfrom:%s\n\tto:%s",srcDir,targetPath)
		fs.copy_dir(srcDir,targetPath,"fm")
	end
end
task.install.Desc = "lua bootstrap install task"

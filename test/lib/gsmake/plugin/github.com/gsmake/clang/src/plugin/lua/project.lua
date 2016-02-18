local fs        = require "lemoon.fs"
local throw     = require "lemoon.throw"
local class     = require "lemoon.class"
local filepath  = require "lemoon.filepath"

local logger    = class.new("lemoon.log","gsmake")
local console    = class.new("lemoon.log","console")

local module = {}

function module.ctor (obj)
    obj.ConfigFiles                 = {};
    obj.SrcFiles                    = {};
    obj.HeaderFiles                 = {};
    obj.Linked                      = {};
    obj.External                    = false;

    for i,pattern in pairs(obj.header_files) do
        obj.header_files[i] = pattern:gsub("(%*%.)","[^.]*%%.")
    end

    for i,pattern in pairs(obj.source_files) do
        obj.source_files[i] = pattern:gsub("(%*%.)","[^.]*%%.")
    end

    for _,dir in ipairs(obj.SrcDirs) do

        fs.match(dir,obj.config,obj.skips,function(path)
            path = filepath.toslash(filepath.clean(path))
            table.insert(obj.ConfigFiles,path)
        end)

        for _,pattern in ipairs(obj.header_files) do
            fs.match(dir,pattern,obj.skips,function(path)
                path = filepath.toslash(filepath.clean(path))
                table.insert(obj.HeaderFiles,path)
            end)
        end

        for _,pattern in ipairs(obj.source_files) do

            fs.match(dir,pattern,obj.source_files,function(path)
                path = filepath.toslash(filepath.clean(path))
                table.insert(obj.SrcFiles,path)
            end)
        end
    end

    return obj
end

function module:link(projects)
    logger:I("%s link...",self.Name)

    local deps = self.Deps

    if type(self.Deps) == "function" then
        logger:V("call %s dependencies function",self.Name)
        deps = deps()
    end

    for _,dep in ipairs(deps) do

        if type(dep) == "table" then
            logger:D("found project [%s] dependency %s",self.Name,dep.name)
            -- link external package
            if dep.version == nil then
                dep.version = self.Loader.Config.DefaultVersion
            end



            -- sync the source package
            local sourcePath = self.Loader.Sync:sync(dep.name,dep.version)

            -- load the package
            local loader = class.new("gsmake.loader",self.Loader.GSMake,sourcePath,dep.name,dep.version)
            loader:load()
            loader:setup()
            loader:run("install",self.OutputDir)

            if dep.module == nil then
                dep.module = {}
                for k,v in pairs(loader.Package.Properties.clang or {}) do
                    if v["type"] ~= "exe" then
                        table.insert(dep.module,k)
                    end
                end
            elseif type(dep.module) == "string" then
                dep.module = { dep.module }
            end

            for _,name in ipairs(dep.module) do

                local proj = {
                    Name           = name;
                    External       = true;
                }

                table.insert(self.Linked,proj)
            end

        else
            local proj = projects[dep]

            if proj == nil then
                throw("[%s] depend inner project [%s] -- not found ",self.Name,dep)
            end

            logger:D("found project [%s] dependency %s",self.Name,dep)
            -- insert proj into linked table
            table.insert(self.Linked,proj)
        end
    end
end


return module
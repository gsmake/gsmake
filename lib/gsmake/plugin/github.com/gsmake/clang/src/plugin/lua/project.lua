local fs        = require "lemoon.fs"
local class     = require "lemoon.class"
local filepath  = require "lemoon.filepath"

local logger    = class.new("lemoon.log","lake")

local module = {}

local function printArray(array)
    local s = "{ "
    for _,v in ipairs(array) do
        s = s .. '"' .. tostring(v) ..'"'
    end

    s = s .. " }"

    return s
end

function module.ctor(lake,name,config)

    local obj = {
        lake                        = lake;
        Name                        = name;
        CMAKE_OUTPUT_DIR            = assert(config.CMAKE_OUTPUT_DIR);
        CMAKE_CONFIG_FILE_NAME      = assert(config.CMAKE_CONFIG_FILE_NAME);
        CMAKE_HEADER_FILES          = assert(config.CMAKE_HEADER_FILES);
        CMAKE_SOURCE_FILES          = assert(config.CMAKE_SOURCE_FILES);
        CMAKE_SKIP_DIRS             = assert(config.CMAKE_SKIP_DIRS);
        Dir                         = assert(config.Dir);
        Deps                        = config.Dependencies or {};
        ConfigFiles                 = {};
        SrcFiles                    = {};
        HeaderFiles                 = {};
        linked                      = {};
    }

    for i,pattern in pairs(obj.CMAKE_HEADER_FILES) do
        obj.CMAKE_HEADER_FILES[i] = pattern:gsub("(%*%.)","[^.]*%%.")
    end

    for i,pattern in pairs(obj.CMAKE_SOURCE_FILES) do
        obj.CMAKE_SOURCE_FILES[i] = pattern:gsub("(%*%.)","[^.]*%%.")
    end

    fs.match(obj.Dir,obj.CMAKE_CONFIG_FILE_NAME,obj.CMAKE_SKIP_DIRS,function(path)
        table.insert(obj.ConfigFiles,filepath.clean(path))
    end)

    for _,pattern in ipairs(obj.CMAKE_HEADER_FILES) do
        fs.match(obj.Dir,pattern,obj.CMAKE_SKIP_DIRS,function(path)
            table.insert(obj.HeaderFiles,filepath.clean(path))
        end)
    end

    for _,pattern in ipairs(obj.CMAKE_SOURCE_FILES) do
        fs.match(obj.Dir,pattern,obj.CMAKE_SKIP_DIRS,function(path)
            table.insert(obj.SrcFiles,filepath.clean(path))
        end)
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
                dep.version = self.lake.Config.GSMAKE_DEFAULT_VERSION
            end

            local sourcePath = self.sync:sync(dep.name,dep.version)

            local package = self.loader:load(sourcePath,dep.name,dep.version)

            package:link()

            package:setup()

            -- TODO: add proj to linked table
        else
            local proj = projects[dep]

            if proj == nil then
                error(string.format("[%s] depend inner project [%s] -- not found ",self.Name,dep))
            end

            logger:D("found project [%s] dependency %s",self.Name,dep)
            -- insert proj into linked table
            table.insert(self.linked,proj)
        end
    end

end

return module

-- the lake package sync services
local fs        = require "lemoon.fs"
local regex     = require "lemoon.regex"
local throw     = require "lemoon.throw"
local class     = require "lemoon.class"

-- cached logger
local logger = class.new("lemoon.log","gsmake")

local module = {}

function module.ctor(lake)
    local obj = {
        lake        = lake;
        db          = lake.DB;
        remotes     = lake.Remotes;
    }

    return obj
end

function module:get_sync_executor(name,version)
    for _,remote in pairs(self.lake.Remotes) do

        local url = regex.gsub(name,remote.Pattern,remote.URL)

        if url ~= name then

            local executorName = string.format("sync.%s",remote.Sync)

            local ok, executor = pcall(class.new,executorName,self.lake,name,version)

            if not ok then
                throw("load sync executor %s err :\n\t%s",executorName,executor)
            end

            logger:I("sync package '%s:%s' -- success ",name,version)

            return true,executor,url
        end
    end

    return false
end

function module:sync_remote(name,version)
    logger:I("sync package '%s:%s' ... ",name,version)

    local ok, executor,url = self:get_sync_executor(name,version)

    if not ok then
        throw("sync package '%s:%s' -- failed,unknown remote site ",name,version)
    end

    executor:sync_remote(url)

    logger:I("sync package '%s:%s' -- success ",name,version)

end

function module:sync_source(name,version)

    local ok, executor = self:get_sync_executor(name,version)

    if not ok then
        throw("sync package '%s:%s' -- failed,unknown remote site ",name,version)
    end

    return executor:sync_source()
end

function module:sync(name,version)

    if version == nil then
        version = self.lake.Config.GSMAKE_DEFAULT_VERSION
    end

    local path,ok = self.db:query_source(name,version)

    if ok and fs.exists(path) then
        return path
    end

    path,ok = self.db:query_sync(name,version)

    if ok and fs.exists(path) then
        return self:sync_source(name,version)
    end

    self:sync_remote(name,version)
    return self:sync_source(name,version)
end

return module

-- the lake package sync services
local fs        = require "lemoon.fs"
local regex     = require "lemoon.regex"
local class     = require "lemoon.class"

-- cached logger
local logger = class.new("lemoon.log","lake")

local module = {}

function module.ctor(lake)
    local obj = {
        lake        = lake;
        db          = lake.DB;
        remotes     = lake.Remotes;
    }

    return obj
end

function module:sync_remote(name,version)
    logger:I("sync package '%s:%s' ... ",name,version)

    for _,remote in pairs(self.lake.Remotes) do

        local url = regex.gsub(name,remote.Pattern,remote.URL)

        if url ~= name then

            local executorName = string.format("sync.%s",remote.Sync)

            local ok, executor = pcall(class.new,executorName,self.lake,name,version)

            if not ok then
                error(string.format("load sync executor %s err :\n\t%s",executorName,executor))
            end

            executor:sync_remote(url)


            logger:I("sync package '%s:%s' -- success ",name,version)

            return
        end
    end

    logger:E("sync package '%s:%s' -- failed,unknown remote site ",name,version)
end

function module:sync_source(name,version)

end

function module:sync(name,version)
    local path,ok = self.db:query_source(name,version)

    if ok and fs.exists(path) then
        return path
    end

    self.db:query_sync(name,version)

    if ok and fs.exists(path) then
        return self:sync_source(name,version)
    end

    self:sync_remote(name,version)
    return self:sync_source(name,version)
end

return module

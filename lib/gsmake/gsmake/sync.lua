local fs        = require "lemoon.fs"
local regex     = require "lemoon.regex"
local throw     = require "lemoon.throw"
local class     = require "lemoon.class"
local module    = {}

function module.ctor (gsmake)
    local obj = {
        gsmake          = gsmake    ;
    }

    return obj
end

function module:get_sync_executor(name,version)
    for _,remote in pairs(self.gsmake.Remotes) do

        local url = regex.gsub(name,remote.Pattern,remote.URL)

        if url ~= name then

            local executorName = string.format("sync.%s",remote.Sync)

            local ok, executor = pcall(class.new,executorName,self.gsmake,name,version)

            if not ok then
                throw("load sync executor %s err :\n\t%s",executorName,executor)
            end

            return true,executor,url
        end
    end

    return false
end

function module:sync_remote(name,version)

    local ok, executor,url = self:get_sync_executor(name,version)

    if not ok then
        throw("sync package '%s:%s' -- failed,unknown remote site ",name,version)
    end

    executor:sync_remote(url)
end

function module:sync_source(name,version)

    local ok, executor = self:get_sync_executor(name,version)

    if not ok then
        throw("sync package '%s:%s' -- failed,unknown remote site ",name,version)
    end

    return executor:sync_source()
end


-- sync package's
function module:sync (name,version)
    local repoDB    = self.gsmake.Repo

    local path,ok = repoDB:query_source(name,version)
    if ok and fs.exists(path) then
        return path
    end

    path,ok = repoDB:query_sync(name,version)

    if ok and fs.exists(path) then
        path = self:sync_source(name,version)
        return path
    end

    self:sync_remote(name,version)
    return self:sync_source(name,version)
end

return module

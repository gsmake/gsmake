local fs        = require "lemoon.fs"
local regex     = require "lemoon.regex"
local throw     = require "lemoon.throw"
local class     = require "lemoon.class"
local filepath  = require "lemoon.filepath"
local module    = {}

function module.ctor (loader)
    local obj = {
        loader          = loader                                ; -- the package loader belongs to
        remotes         = class.clone(loader.GSMake.Remotes)    ;
        localremotes    = {}                                    ; -- locall remotes config
    }

    local remotesfile = filepath.join(loader.Path,".remotes.lua")

    if fs.exists(remotesfile) then
        local env = sandbox.new("gsmake.sandbox.remotes")

        obj.localremotes = sandbox.run(remotesfile,env)
    end

    return obj
end

function module:geturl(name,version,remotes)

    local url = nil

    for _,remote in pairs(remotes) do

        if remote.Pattern then
            url = regex.gsub(name,remote.Pattern,remote.URL)
            if url == name then url = nil end
        elseif remote.Match == name then
            url = remote.URL
        end

        if url ~= nil then
            local downloader = remote.Downloader
            if downloader.version == nil then
                downloader.version = self.loader.Config.DefaultVersion
            end

            return url:gsub("%${version}",version),remote.Downloader
        end
    end
end

function module:get_sync_executor(name,version)

    local url,downloader = self:geturl(name,version,self.localremotes)

    if not url then
        url,downloader = self:geturl(name,version,self.remotes)
    end

    if url then
        local path = self:sync(downloader.name,downloader.version)

        local plugin = class.new("gsmake.plugin",downloader.name,self.loader.Package)
        plugin:version(downloader.version)
        plugin:load()
        plugin:setup()

        local loader = plugin.Loader
        local package = plugin.Package
        package.Plugins[package.Name] = plugin

        return true,loader,url
    end

    return false
end



function module:sync_remote(name,version)

    local ok, executor,url = self:get_sync_executor(name,version)

    if not ok then
        throw("sync package '%s:%s' -- failed,unknown remote site ",name,version)
    end

    if executor:run("sync_remote",name,version,url) then
        throw("sync package '%s:%s' -- failed",name,version)
    end

end

function module:sync_source(name,version)

    local ok, executor = self:get_sync_executor(name,version)

    if not ok then
        throw("sync package '%s:%s' -- failed,unknown remote site ",name,version)
    end

    if executor:run("sync_source",name,version) then
        throw("sync package '%s:%s' -- failed",name,version)
    end
    local repoDB    = self.loader.GSMake.Repo
    local ok,path = repoDB:query_source(name,version)
    print(name,version)
    assert(ok,string.format("detect downloader[%s:%s] bug",executor.Package.Name,executor.Package.Version))
    return path
end


-- sync package's
function module:sync (name,version)

    if name == nil or version == nil then
        throw("sync:sync invalid args :%s,%s",name,version)
    end

    local repoDB    = self.loader.GSMake.Repo

    local ok,path,cached = repoDB:query_source(name,version)

    if ok and fs.exists(path) then
        return path
    end

    ok,path = repoDB:query_sync(name,version)

    if ok and fs.exists(path) then
        path = self:sync_source(name,version)
        return path
    end

    self:sync_remote(name,version)
    return self:sync_source(name,version)
end

return module

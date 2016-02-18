local fs        = require "lemoon.fs"
local sys       = require "lemoon.sys"
local class     = require "lemoon.class"
local filepath  = require "lemoon.filepath"
local logger    = class.new("lemoon.log","gsmake")
local console   = class.new("lemoon.log","console")


task.sync_init = function(self)
    if sys.host() == "Windows" then
        curl = filepath.join(self.Package.Path,"tools/win32/curl.exe")
        unzip = filepath.join(self.Package.Path,"tools/win32/7z.exe")
    else
        local ok, curlpath = sys.lookup("curl")
        if not ok then
            throw("curl program not found !!!!!!!")
        end

        curl = curlpath

        local ok, unzippath = sys.lookup("7z")
        if not ok then
            throw("7z program not found !!!!!!!")
        end

        unzip = unzippath
    end


end

task.sync_remote = function(self,name,version,url)
    print(string.format("sync remote package:%s",url))

    local workdir = filepath.join(loader.Config.GlobalRepo,"curl",name)

    if not fs.exists(workdir) then
        fs.mkdir(workdir,true)
    end

    print(curl)

    local exec = sys.exec(curl)
    exec:dir(workdir)
    -- --
    local tmpfile = string.format("%s.tmp",version)
    --
    exec:start("-o",tmpfile,"-k",url)

    if 0 ~= exec:wait() then
        console:E("download remote package error :%s",url)
        return true
    end

    local outputdir = filepath.join(workdir,version)

    -- if fs.exists(outputdir) then
    --     fs.rm(outputdir,true)
    -- end

    local exec = sys.exec(unzip)
    exec:dir(workdir)


    exec:start("x","-aoa",string.format("-o%s",version),filepath.join(workdir,tmpfile))

    if 0 ~= exec:wait() then
        console:E("download remote package error :%s",url)
        return true
    end


    local sourcepath = nil

    fs.list(outputdir,function(entry)
        if entry == "." or entry == ".." then return end
        sourcepath = filepath.join(outputdir,entry)
    end)

    assert(sourcepath,"7z bug checker")

    loader.GSMake.Repo:save_source(name,version,sourcepath,sourcepath,true)

end
task.sync_remote.Desc = "curl downloader#sync_remote"
task.sync_remote.Prev = "sync_init"


task.sync_source = function(self,install_path)

end
task.sync_source.Desc = "curl downloader#sync_source"
task.sync_source.Prev = "sync_init"

--
-- Created by IntelliJ IDEA.
-- User: yayanyang
-- Date: 16/9/8
-- Time: 下午4:57
-- To change this template use File | Settings | File Templates.
--
local fs        = require "lemoon.fs"
local class     = require "lemoon.class"
local logger    = class.new("lemoon.log","gsmake")
local logsink   = require "lemoon.logsink"
local filepath  = require "lemoon.filepath"
local module    = {}


local openlog = function(gsmake)

    local name = "gsmake" .. os.date("-%Y-%m-%d-%H_%M_%S")

    local path = filepath.join(gsmake.config.workspace,gsmake.config.tempdir,"log")
    print(path)
    if not fs.exists(path) then

        fs.mkdir(path,true)
    end

    logsink.file_sink(
        "",
        path,
        name,
        ".log",
        false,
        1024*1024*10)
end

-- gsmake initializer
function module.ctor()
    local gsmake = { config = {} }

    gsmake.config.home = os.getenv("GSMAKE_HOME")
    gsmake.config.workspace = fs.dir()
    gsmake.config.tempdir = ".gsmake"

    local configsandbox = class.new("gsmake.sandbox")

    configsandbox:dofile(filepath.join(gsmake.config.workspace,"etc/config.lua"),{
        config = gsmake.config
    })

    openlog(gsmake)

    logger:I("gsmake home :%s",gsmake.config.home)
    logger:I("gsmake workspace :%s",gsmake.config.workspace)

    return gsmake
end

-- install package
function module:install(global, packages)

end

return module


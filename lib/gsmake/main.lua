--
-- this file is gsmake boostrap lua script file
--

require "gsmake"
_ENV = sandbox.new()


local fs        = require "lemoon.fs"
local class     = require "lemoon.class"
local console   = class.new("lemoon.log","console")

local options = {

    ["^-host"] = {
        value = true;

        call = function (config,val)
            local host = require "gsmake.host"
            if not host[val] then
                console:W("TargetHost(%s) not changed : unsupport host %s",gsmake.Config.TargetHost,val)
                return
            end

            config.TargetHost = val
        end
    };

    ["^-arch"] = {
        value = true;

        call = function (config,val)
            local arch = require "gsmake.arch"
            if not arch[val] then
                console:W("TargetArch(%s) not changed : unsupport arch %s",gsmake.Config.TargetArch,val)
                return
            end

            config.TargetArch = val
        end
    };

    ["^-reload"] = {
        call = function (config)
            config.Reload = true
        end;
    };

    ["^-config"] = {
        value = true;

        call = function (config,val)
            config.BuildConfig = val
        end;
    }
}


local function parseoptions (gsmake,args)

    local skip = false

    for i,arg in ipairs(args) do
        if not skip then
            local stop = true
            for option,ctx in pairs(options) do
                if arg:match(option) then
                    local val = nil
                    if ctx.value then
                        val = arg:sub(#option)
                        if not val or val == "" then
                            val = args[i + 1]
                            skip = true
                        end

                        if not val  or val == ""  then
                            throw("expect option(%s)'s val ",option:sub(2))
                        end
                    end

                    ctx.call(gsmake,val)
                    stop = false
                    break
                end
            end

            if stop then
                return table.pack(table.unpack(args,i))
            end
        else
            skip = false
        end
    end

    return {}
end
--
--
local main = function  ()

    local config      = class.clone(require "config")
    local remotes     = class.clone(require "remotes")
    local args        = parseoptions(config,arg)

    local gsmake = class.new("gsmake.gsmake",config,remotes)

    if gsmake:run(table.unpack(args)) then
      console:E("run gsmake -- failed !!!!!")
    end
end


local ok,msg = pcall(main)

if not ok then
    console:E("%s",msg)
end

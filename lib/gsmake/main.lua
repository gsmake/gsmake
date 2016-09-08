--
-- this file is gsmake boostrap lua script file
--
local cli       = require "cliargs"
local class     = require "lemoon.class"
local console   = class.new("lemoon.log","console")
local gsmake    = class.new("gsmake")

cli:set_name("gsmake")

cli
    :command("install", "installs dependencies from ./.gsmake.lua or specify one or more gsmake package")
    :flag("-g --global","install package into global directory")
    :splat("PACKAGES","installing package list",nil,99)
    :action(function(options)
        for i,v in ipairs(options.PACKAGES) do
            console:I("%d %s",i,v)
        end
    end)

local parseargs = function()
    local args, err = cli:parse(arg)

    if not args and err then
        console:E(string.format('%s: %s; re-run with help for usage', cli.name, err))
        return false
    end

    return true, args
end

local main = function  ()
    local ok = parseargs()

    if not ok then return end
end


local ok,msg = pcall(main)

if not ok then
    console:E("%s",msg)
end

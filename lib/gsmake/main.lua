--
-- this file is gsmake boostrap lua script file
--
local fs        = require "lemoon.fs"
local class     = require "lemoon.class"

local main = function  (args)
    local gsmake = class.new("gsmake",fs.dir(),"GSMAKE_HOME")

    gsmake:run(table.unpack(arg))
end


local ok,msg = pcall(main)

if not ok then
    print(msg)
end

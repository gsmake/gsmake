--
-- this file is gsmake boostrap lua script file
--

require "gsmake"
_ENV = sandbox.new()


local fs        = require "lemoon.fs"
local class     = require "lemoon.class"
local console   = class.new("lemoon.log","console")
--
--
local main = function  ()
    local gsmake = class.new("gsmake.gsmake",fs.dir(),"GSMAKE_HOME")

    gsmake:run(table.unpack(arg))
end


local ok,msg = pcall(main)

if not ok then
    console:E("%s",msg)
end

--
-- this file is gsmake boostrap lua script file
--
local fs        = require "lemoon.fs"
local class     = require "lemoon.class"

local lake = class.new("lake",fs.dir())

lake:run(table.unpack(arg))







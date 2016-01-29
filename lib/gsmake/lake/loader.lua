local class = require "lemoon.class"


-- cached logger
local logger = class.new("lemoon.log","gsmake")

local module = {}


function module.ctor(lake)

    local obj =
    {
        lake            = lake;
        checkerOfDCG    = {};
        packages        = {};
    }

    return obj
end

function module:load(path,name,version)
    
    local package = class.new("lake.package",self.lake,path,name,version)

    self.packages[package.Name] = package

    return package
end

return module

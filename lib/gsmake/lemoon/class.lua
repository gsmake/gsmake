local throw = require "lemoon.throw"

local module = {}

function module.new(name,...)

    local ok,metatable = pcall(require,name)

    if not ok then
        throw("load class error\n%s",metatable)
    end

    if type(metatable) ~= "table" then
        throw("class(%s) script must return table val",name)
    end

    local obj

    if metatable.ctor ~= nil then
        obj = metatable.ctor(...)
        assert(obj ~= nil,string.format("class(%s) ctor must return table val",name))
    else
        obj = {...}
    end

    setmetatable(obj,{
         __index = metatable;
         __gc =metatable.final;
     })

    return obj
end

function module.clone(prototype)
    local obj = {}

    for k,v in pairs(prototype) do
        obj[k] = v
    end

    if getmetatable(prototype) ~= nil then
        setmetatable(obj,getmetatable(prototype))
    end

    return obj

end


return module

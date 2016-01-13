local module = {}

function module.new(name,...)

    local metatable = require(name)

    assert(type(metatable) == "table",string.format("class(%s) script must return table val",name))

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

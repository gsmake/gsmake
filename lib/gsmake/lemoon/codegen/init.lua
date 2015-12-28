local class     = require "lemoon.class"
local logger    = class.new("lemoon.log","lemoon")

local module    = {}
-- create new codegen by template text
function module.ctor (tpl)
    return {
        tpl         = tpl;
        Writer      = class.new("lemoon.codegen.memory");
    }
end

-- render new text codes by provide env
function module:render (env)

end

return module

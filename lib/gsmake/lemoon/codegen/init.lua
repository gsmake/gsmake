local class     = require "lemoon.class"
local module    = {}

function module.ctor ()
    return {
        templates = {};
    }
end
--
function docompile (args)

end

function module:compile (name,tpl)
    self.templates[name] = class.new("lemoon.codegen.render",name,tpl)
end

return module

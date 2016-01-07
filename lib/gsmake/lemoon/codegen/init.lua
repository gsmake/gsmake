local class     = require "lemoon.class"
local module    = {}
local logger    = class.new("lemoon.log","lemoon.codegen")

function module.ctor ()
    return {
        templates = {};
    }
end
--
function docompile (args)

end

function module:compile (name,tpl)
    self.templates[name] = class.new("lemoon.codegen.render",self,name,tpl)
end

function module:render (writer,name,env)
    local render = self.templates[name]
    if render == nil then
        error(string.format("unknown template(%s)",name),2)
    end

    if type(writer) == "string" then
        writer = class.new("lemoon.codegen.file",writer)
    end

    render:eval(writer,env)
end

return module

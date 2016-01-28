local throw     = require "lemoon.throw"
local class     = require "lemoon.class"
local module    = {}


function module.ctor ()
    return {
        templates = {};
    }
end


function module:compile (name,tpl)
    self.templates[name] = class.new("lemoon.codegen.render",self,name,tpl)
end

function module:render (writer,name,env)
    local render = self.templates[name]
    if render == nil then
        throw("unknown template(%s)",name)
    end

    if type(writer) == "string" then
        writer = class.new("lemoon.codegen.file",writer)
        local ok ,err = pcall(render.eval,render,writer,env)
        writer:final()

        if not ok then
            throw(err)
        end
    else
        render:eval(writer,env)
    end


end

return module

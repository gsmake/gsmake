local module = {}

function module.ctor (name)

    local obj = {
        template = require(name);
    }

    return obj

end

function module:gen(args)
    if type(args) ~= "table" then
        error("template generate args must be table",2)
    end

    local txt = self.template:gsub("%${(%w+)}",args)

    return txt
end

return module

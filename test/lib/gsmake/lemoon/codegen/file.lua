local throw  = require "lemoon.throw"
local module = {}

function module.ctor(path)
    local file,err = io.open(path,"w+")

    if not file then
        throw(err)
    end

    return {
        file = file;
    }
end

function module:write (args)
    self.file:write(args)
    self.file:flush()
end

function module:final ()
    if self.file  ~= nil then
        self.file:close()
        self.file = nil
    end
end

return module

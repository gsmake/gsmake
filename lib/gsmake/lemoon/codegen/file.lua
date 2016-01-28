local module = {}

function module.ctor(path)
    return {
        file = io.open(path,"w+")
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

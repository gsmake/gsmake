local module = {}

function module.ctor(path)
    return {
        file = io.open(path,"w+")
    }
end

function module:write (args)
    self.file:write(args)
end

function module:final ()
    self.file:close()
end

return module

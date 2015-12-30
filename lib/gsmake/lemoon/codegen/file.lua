local module = {}

function module.ctor (path)
    return {
        file = assert(io.open(path,"w+"));
    }
end

function module:write (txt)
    self.file:write(txt)
end

function module:final()
    self.file:close()
end

return module

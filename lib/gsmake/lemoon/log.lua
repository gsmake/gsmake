local __lemoon_log = require "lemoonc.log"

local class = {}

function class:write(level,fmt,...)

    local ok,msg = pcall(string.format,fmt,...)

    if not ok then
        error("invalid log args\n\t" .. msg,3)
    end

    __lemoon_log.log(self.source,level,msg)

end

function class:E(fmt,...)
    self:write(1,fmt,...)
end

function class:W(fmt,...)
    self:write(2,fmt,...)
end

function class:I(fmt,...)
    self:write(4,fmt,...)
end

function class:D(fmt,...)
    self:write(8,fmt,...)
end

function class:T(fmt,...)
    self:write(16,fmt,...)
end

function class:V(fmt,...)
    self:write(32,fmt,...)
end

function class:exit()
    __lemoon_log.exit()
end

function class.ctor(name)

    local log = {}

    log.source = __lemoon_log.get(name)

    return log
end

return class

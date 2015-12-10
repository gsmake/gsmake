local __lemoon_log = require "lemoonc.log"

local class = {}

function class:E(fmt,...)
    __lemoon_log.log(self.source,1,string.format(fmt,...))
end

function class:W(fmt,...)
    __lemoon_log.log(self.source,2,string.format(fmt,...))
end

function class:I(fmt,...)
    __lemoon_log.log(self.source,4,string.format(fmt,...))
end

function class:D(fmt,...)
    __lemoon_log.log(self.source,8,string.format(fmt,...))
end

function class:T(fmt,...)
    __lemoon_log.log(self.source,16,string.format(fmt,...))
end

function class:V(fmt,...)
    __lemoon_log.log(self.source,32,string.format(fmt,...))
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

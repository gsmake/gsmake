--
-- Created by IntelliJ IDEA.
-- User: yayanyang
-- Date: 16/9/8
-- Time: 下午5:24
-- To change this template use File | Settings | File Templates.
--
local throw 		= require "lemoon.throw"
local module        = {}

function module.ctor()
    local sandbox = {}

    return sandbox
end

function module:dofile(script,env)
    for k,v in pairs(_G) do
        env[k] = v
    end

    local block,err = loadfile(script,"bt", env)

    if err ~= nil then
        throw(err)
    end

    return block()
end

-- sandbox call with fn
function module:call(fn, env, ...)

    for k,v in pairs(_G) do
        env[k] = v
    end

    local idx = 1
    while true do
        local name,_ = debug.getupvalue(fn, idx)

        if not name then break end

        if name == "_ENV" then
            debug.setupvalue(fn,idx,env)
            break
        end

        idx = idx + 1
    end

    return fn(...)
end

return module


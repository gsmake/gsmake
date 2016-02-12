
local module    = {}

function module.ctor(env,loader)
    env.loader  = loader
end

return module

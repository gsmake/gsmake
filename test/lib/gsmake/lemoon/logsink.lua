local __lemoon_log = require "lemoonc.log"

local module = {}

for k, v in pairs(__lemoon_log) do
    module[k] = v
end

module.get = nil
module.log = nil
module.close = nil

return module

local module = require "lemoonc.os"


module.SO_NAME = ".so"

if module.host() == "Windows" then
    module.SO_NAME = ".dll"
end

module.EXE_NAME = ""

if module.host() == "Windows" then
    module.SO_NAME = ".exe"
end

return module

local module = require "lemoonc.os"


module.SO_NAME = ".so"

if module.host() == "Win32" or module.host() == "Win64" then
    module.SO_NAME = ".dll"
end

module.EXE_NAME = ""

if module.host() == "Win32" or module.host() == "Win64" then
    module.SO_NAME = ".exe"
end

return module
local class     = require "lemoon.class"
local module    = {}
local logger    = class.new("lemoon.log","lemoon.codegen")

-- parse the tpl
function module.ctor (name,tpl)
    local obj   = { Name = name; }
    local lexer = class.new("lemoon.codegen.lexer",tpl)
    logger:I("compile template(%s) ...",name)

    for type,token in lexer:tokens() do
        logger:I("%s",token)
    end
    return obj
end

return module

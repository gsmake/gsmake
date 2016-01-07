local class     = require "lemoon.class"
local module    = {}
local logger    = class.new("lemoon.log","lemoon.codegen")

function module.ctor (name,src)
    return {
        name    = name;
        src     = src;
        pos     = 1;
        plain   = true;
    }
end

local function next (lexer)

    if lexer.pos >= #lexer.src then
        return nil
    end

    if lexer.plain then
        local from,to = lexer.src:find("@{{",lexer.pos,true)
        if from == nil then
            local token = lexer.src:sub(lexer.pos)
            lexer.pos = #lexer.src
            return true,token
        else
            local token = lexer.src:sub(lexer.pos,from - 1)
            lexer.pos = to + 1
            lexer.plain = false
            return true,token
        end
    else
        local from,to = lexer.src:find("}}",lexer.pos,true)
        if from == nil then
            error(string.format("unclosed code block(%s)",lexer.name))
        end
        local token = lexer.src:sub(lexer.pos,from - 1)
        lexer.pos = to + 1
        lexer.plain = true
        return false,token
    end
end

-- get next token
function module:tokens ()
    return function ()
        return next(self)
    end,self
end

return module

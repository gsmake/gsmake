local module = {}

function module.ctor (src)
    return {
        src = src;
        pos = 1;
    }
end

local function next (lexer)
    if lexer.pos == #lexer.src then
        return nil
    end

    lexer.src:sub(lexer.pos,lexer.pos)
end

-- get next token
function module:tokens ()
    return function ()
        return next(self)
    end,self
end

return module

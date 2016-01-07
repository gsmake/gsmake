local class     = require "lemoon.class"
local module    = {}
local logger    = class.new("lemoon.log","lemoon.codegen")

local keys = {"for","if","else","elseif","end"}

-- parse the tpl
function module.ctor (codegen,name,tpl)
    local obj   = { Name = name; codegen = codegen;}
    local lexer = class.new("lemoon.codegen.lexer",name,tpl)

    logger:I("compile template(%s) ...",name)

    local render_src = ""

    for plain,token in lexer:tokens() do
        if plain then
            render_src = render_src .. string.format("__codegen_writer:write([[%s]])\n",token)
        else
            token = token:gsub("^%s*(.-)%s*$", "%1")
            local isvar = true

            for _,key in ipairs(keys) do
                if token:sub(1,#key)==key then
                    isvar = false
                    break
                end
            end

            if token:sub(1,#"include")=="include" then
                local args = {}
                for arg in token:sub(#"include"+1):gmatch("[^,%)%(]+") do
                    table.insert(args,arg)
                end
                logger:I("include(%s,%s)",args[1],args[2])

                if(args[2] == nil) then
                    args[2] = "_ENV"
                end

                render_src = render_src .. string.format("__codegen_render('%s',%s)\n",args[1],args[2])
            elseif isvar then
                render_src = render_src .. string.format("__codegen_writer:write(tostring(%s))\n",token)
            else
                render_src = render_src .. token .. "\n"
            end


        end
    end

    obj.render = render_src

    return obj
end

function module:eval(writer,env)
    env.__codegen_render = function(name,env)
        logger:I("include ................")
        self.codegen:render(writer,name,env)
    end
    env.__codegen_writer = writer

    for k,v in pairs(_G) do
        env[k] = v
    end

    logger:I("render script(%s) :\n%s",self.Name,self.render)

    local func,err = load(self.render,self.Name,"bt",env)

    if func == nil then
        error(string.format("load %s error :%s",self.Name,err))
    end

    func()

end

return module

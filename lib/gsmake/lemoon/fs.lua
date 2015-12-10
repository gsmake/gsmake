local class     = require "lemoon.class"
local logger    = class.new("lemoon.log","lemoon")

local module = require "lemoonc.fs"

function module.copy_file(source,target)

    local srcFile = io.open(source, "r")

    local srcData = srcFile:read("*a")

    srcFile:close()

    local targetFile = io.open(target, "w")
    targetFile:write(srcData)
    targetFile:close()
end

function module.copy_dir_and_children(from,to,skipdirs)
    assert(module.isdir(from),"source must be dir")

    if module.exists(to) then
        module.rm(to,true)
    end

    local ok,err = pcall(module.mkdir,to,true)

    if not ok then
        logger:E("create dir :%s -- failed",to)
        error(debug.traceback() .. "\n\t" .. err)
    end


    module.list(from,function(entry)
        if entry == "." or entry == ".." then return end

        for _,v in pairs(skipdirs) do
            if v == entry then return end
        end

        local source = from .. "/".. entry
        local target = to .. "/".. entry

        if module.isdir(source) then
            module.copy_dir_and_children(source,target,skipdirs)
        else
            module.copy_file(source,target)
        end
    end)
end

return module

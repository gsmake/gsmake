local throw     = require "lemoon.throw"
local class     = require "lemoon.class"
local logger    = class.new("lemoon.log","lemoon")

local module = require "lemoonc.fs"

module.none = 0
module.skip_existing = 1
module.overwrite_existing = 2
module.update_existing = 4
module.recursive = 8
module.copy_symlinks = 16
module.skip_symlinks = 32
module.directories_only = 64
module.create_symlinks = 128
module.create_hard_links = 256

-- copy the directory to target path
function module.copy_dir(from,to,flags)
    if module.exists(to) then

        if flags & module.skip_existing ~= 0 then
            return
        elseif flags & module.overwrite_existing ~= 0 then
            module.rm(to,true)
        elseif flags & module.update_existing == 0 then
            throw("copy directory error: already exists\n\tfrom: %s\n\tto: %s",from,to)
        end

    end

    if not module.exists(to) then
        module.mkdir(to,true)
    end

    module.list(from,function(entry)
        if entry == "." or entry == ".." then return end

        local src = from .. "/".. entry
        local obj = to .. "/".. entry

        if module.isdir(src) then
            module.copy_dir(src,obj,flags)
        else
            module.copy_file(src,obj,flags)
        end
    end)
end


function module.match(path,pattern,skipdirs,fn)
    module.list(path,function(entry)
        if entry == "." or entry == ".." then return end

        for _,v in pairs(skipdirs or {}) do
            if v == entry then return end
        end

        local childpath = path .. "/".. entry

        if module.isdir(childpath) then
            module.match(childpath,pattern,skipdirs,fn)
        else
            if entry:match(pattern) == entry then
                fn(path .. "/" .. entry)
            end
        end
    end)
end

return module

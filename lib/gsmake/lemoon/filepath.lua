--
-- Created by IntelliJ IDEA.
-- User: liyang
-- Date: 15/11/30
-- Time: 上午11:33
-- To change this template use File | Settings | File Templates.
--

local sys = require "lemoon.sys"
local fs = require "lemoon.fs"

local module = {}

-- init os path separator
if  sys.host() == "Win32" or sys.host() == "Win64" then
    module.os_separator = '\\'
else
    module.os_separator = '/'
end


local function isslash(c)
    return c == '\\' or c == '/'
end

local function volume_name_length(path)
    if #path < 2 then return 0 end

    local c = path:sub(1,1)

    if path:sub(2,2) == ':' and (('a' <= c and c <= 'z') or ('A' <= c and c <= 'Z')) then
        return 2
    end

    -- is it UNC
    if #path >= 5 and isslash(path:sub(1,1)) and isslash(path:sub(2,2)) and (not isslash(path:sub(3,3)) and path:sub(3,3) ~= '.') then
        for n = 4, #path - 1 do

            if isslash(path:sub(n,n)) then
                n = n + 1

                if not isslash(path:sub(n,n)) then
                    if path:sub(n,n) == '.' then break end

                    for j = n, #path do
                        if isslash(path:sub(j,j)) then return j end
                    end

                    return #path
                end
            end
        end
    end
    return 0
end

function module.isabs(path)
    local vollen = volume_name_length(path)

    if vollen == 0 then return false end

    path = path.sub(vollen+1)

    if path == "" then return false end

    return isslash(path:sub(1,1))
end

function module.base(path)

    if path == "" then return '.' end

    path = module.clean(path)

    if isslash(path:sub(#path,#path)) then
        path = path:sub(1,#path -1)
    end

    local vollen = volume_name_length(path)

    if vollen > 0 then
        path = path:sub(vollen + 1)
    end

    if path == "" then
        return module.os_separator
    end

    for i = #path,1,-1 do
        if isslash(path:sub(i,i)) then
            path = path:sub(i + 1)
            break
        end
    end

    return path

end

function module.volume(path)
    local vollen = volume_name_length(path)
    if vollen > 0 then
        return path:sub(1,vollen)
    end



    return ""
end

function module.dir(path)

    path = module.clean(path)

    local vollen = volume_name_length(path)

    if isslash(path:sub(#path,#path)) then
        path = path:sub(1,#path -1)
    end

    for i = #path,vollen,-1 do
        if isslash(path:sub(i,i)) then
            path = path:sub(1,i)
            break
        end
    end

    return path

end

function module.ext(path)
    return module.base(path):match("%.[^%.]+$")
end

-- get absolute path
function module.abs(path)

    if  sys.iswindows() then return fs.fullpath(path) end

    if module.isabs(path) then return module.clean(path) end

    return module.join(fs.current(),path)
end

function module.split(path)
    return module.dir(path),module.base(path)
end

function module.fromslash(path)
    local path = path:gsub("/","\\")

    return path
end

function module.toslash(path)
    local path = path:gsub("\\","/")
    return path
end

-- return shortest path name equivalent to path
function module.clean(path)

    local vollen = volume_name_length(path)

    local original = path

    path = path:sub(vollen + 1)

    if path == "" then
        if vollen > 1 and original:sub(2,2) ~= ':' then
            return module.fromslash(original)
        end

        return original .. "."
    end

    local rooted = isslash(path:sub(1,1))

    local i = 1

    local nodes = {}

    path:gsub("[^\\/]+",function(s)

        if s == '.' then return end

        if s == ".." and i >  1 then
            i = i - 1
            return
        end

        nodes[i] = s

        i = i + 1
    end)



    if i == 1 then
        nodes[1] = '.'
        i = 2
    end

    local header =  module.volume(original)
    if rooted then
        header = header .. module.os_separator
    end

    return header .. module.__join(table.unpack(nodes,1,i - 1))
end

function module.join(...)
    local path = module.__join(...)

    return module.clean(path)
end

function module.__join(...)
    local path = ""

    for k,v in pairs {...} do
        path = path .. v .. module.os_separator
    end

    return path:sub(1,#path - 1)
end

return module

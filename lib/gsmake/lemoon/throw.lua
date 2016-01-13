local function throw (fmt,...)
    error(debug.traceback(string.format(fmt,...),2),2)
end

return throw

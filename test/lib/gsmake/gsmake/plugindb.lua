local fs        = require "lemoon.fs"
local class     = require "lemoon.class"
local throw     = require "lemoon.throw"
local filepath  = require "lemoon.filepath"
local sqlite3   = require "lemoon.sqlite3"
local module    = {}

local sqlexec = function(db,sql)
    local id, err = db:exec(sql)

    if err ~= nil then
        throw("%s\n\t%s",sql,err)
    end

    return id
end

function module.ctor (loader,path)

    local obj = {
        Loader          = loader                            ;
        Path            = path                              ; -- the global package cached repo path
        dbPath          = filepath.join(path,"plugin.db")     ; -- database fullpath
    }



    module.exec(obj,function(db)
        sqlexec(db, [[
            create table if not exists _PLUGIN
            (
               _NAME        TEXT,
               _PATH        TEXT,
               _SOURCE      TEXT,
               _VERSION     TEXT
            );
            create unique index if not exists _PLUGIN_FULLNAME_INDEXER ON _PLUGIN (_NAME,_VERSION);
        ]])
    end)

    return obj
end

function module:exec (f)

    local db = assert(sqlite3.open(self.dbPath)) ;

    local result = { f(db) }

    db:close()

    return table.unpack(result)
end

function module:query_plugin(name,version)
    local SQL = string.format('SELECT * FROM _PLUGIN WHERE _NAME="%s" and _VERSION="%s"',name,version)

    return self:exec(function(db)
        for _,path,source,_,_ in db:urows(SQL) do
            return true,path,source
        end

        return false
    end)
end

function module:remove_plugin(name,version)
    local SQL = string.format('delete FROM _PLUGIN WHERE _NAME="%s" and _VERSION="%s"',name,version)

    self:exec(function(db)
        sqlexec(db,SQL)
    end)
end

function module:save_plugin(name,version,path,source,force)

    if force then
        self:remove_plugin(name,version)
    end

    local SQL = string.format('insert into _PLUGIN VALUES("%s","%s","%s","%s")',name,path,source,version)

    self:exec(function(db)
        sqlexec(db,SQL)
    end)

end

return module

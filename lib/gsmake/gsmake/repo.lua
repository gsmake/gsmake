local fs        = require "lemoon.fs"
local class     = require "lemoon.class"
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

function module.ctor (gsmake,path)

    local obj = {
        GSMake          = gsmake                            ;
        Path            = path                              ; -- the global package cached repo path
        dbPath          = filepath.join(path,"repo.db")     ; -- database fullpath
    }

    module.exec(obj,function(db)
        sqlexec(db, [[
            create table if not exists _SOURCE
            (
               _NAME        TEXT,
               _PATH        TEXT,
               _SOURCE      TEXT,
               _VERSION     TEXT,
               _CACHED      BOOLEAN
            );
            create unique index if not exists _SOURCE_FULLNAME_INDEXER ON _SOURCE (_NAME,_VERSION);
            create table if not exists _SYNC
            (
               _NAME        TEXT,
               _PATH        TEXT,
               _SOURCE      TEXT,
               _VERSION     TEXT,
               _PROTOCOL    TEXT
            );
            create unique index if not exists _SYNC_FULLNAME_INDEXER ON _SYNC (_NAME,_VERSION,_PROTOCOL);
        ]])
    end)

    return obj
end

function module:exec (f)

    local db = assert(sqlite3.open(self.dbPath))

    local result = { f(db) }

    db:close()

    return table.unpack(result)
end

function module:query_source(name,version)
    local SQL = string.format('SELECT * FROM _SOURCE WHERE _NAME="%s" and _VERSION="%s"',name,version)

    return self:exec(function(db)
        for _,path,_,_ in db:urows(SQL) do
            return path,true
        end

        return "",false
    end)
end

function module:query_sync(name,version)
    local SQL = string.format('SELECT * FROM _SYNC WHERE _NAME="%s" and _VERSION="%s"',name,version)

    return self:exec(function(db)
        for _,path,_,_,_ in db:urows(SQL) do
            return path,true
        end

        return "",false
    end)
end

function module:remove_sync(name,version)
    local SQL = string.format('delete FROM _SYNC WHERE _NAME="%s" and _VERSION="%s"',name,version)

    self:exec(function(db)
        sqlexec(db,SQL)
    end)
end

function module:save_sync(name,version,source,path,sync,force)

    if force then
        self:remove_sync(name,version)
    end

    local SQL = string.format('insert into _SYNC VALUES("%s","%s","%s","%s","%s")',name,path,source,version,sync)

    self:exec(function(db)
        sqlexec(db,SQL)
    end)

end

function module:remove_source(name,version)

    local SQL = string.format('delete FROM _SOURCE WHERE _NAME="%s" and _VERSION="%s"',name,version)

    self:exec(function(db)
        sqlexec(db,SQL)
    end)
end


function module:save_source(name,version,source,path,force)

    if force then
        self:remove_source(name,version)
    end

    local SQL = string.format('insert into _SOURCE VALUES("%s","%s","%s","%s",%d)',name,path,source,version,0)

    self:exec(function(db)
        sqlexec(db,SQL)
    end)

end

return module

local throw = require "lemoon.throw"
local class = require "lemoon.class"
local sqlite3 = require "lemoon.sqlite3"
local filepath = require "lemoon.filepath"

-- cache the logger object
local logger = class.new("lemoon.log","gsmake")


local module = {}

local sqlexec = function(db,sql)
    local id, err = db:exec(sql)

    if err ~= nil then
        throw("%s\n\t%s",sql,err)
    end

    return id
end

function module:localdb(f)

    local db = assert(sqlite3.open(filepath.join(self.lake.Config.GSMAKE_INSTALL_PATH,"gsmake.db")))

    local result = { f(db) }

    db:close()

    return table.unpack(result)
end

function module:globaldb(f)

    local db = assert(sqlite3.open(filepath.join(self.lake.Config.GSMAKE_REPO,"repo.db")))

    local result = { f(db) }

    db:close()

    return table.unpack(result)
end

function module.ctor(lake)

    local obj = {
        lake = lake;
    }

    logger:T("open gsmake database ...")

    module.localdb(obj,function(db)
        sqlexec(db, [[
            create table if not exists _INSTALL
            (
               _NAME        TEXT,
               _PATH        TEXT,
               _SOURCE      TEXT,
               _VERSION     TEXT,
               _HOST        TEXT
            );
            create unique index if not exists _INSTALL_FULLNAME_INDEXER ON _INSTALL (_NAME,_VERSION,_HOST);
        ]])
    end)

    module.globaldb(obj,function(db)
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
               _SYNC        TEXT
            );
            create unique index if not exists _SYNC_FULLNAME_INDEXER ON _SYNC (_NAME,_VERSION,_SYNC);
        ]])
    end)

    logger:T("open gsmake database -- success")

    return obj
end

-- query install package path
function module:query_install(name,version)

    local SQL = string.format('SELECT * FROM _INSTALL WHERE _NAME="%s" and _VERSION="%s" and _HOST="%s"',name,version,self.lake.GSMAKE_TARGET_HOST)

    return self:localdb(function(db)
        for _,path,_,_ in db:urows(SQL) do
            return true,path
        end

        return false
    end)
end

function module:query_source(name,version)
    local SQL = string.format('SELECT * FROM _SOURCE WHERE _NAME="%s" and _VERSION="%s"',name,version)

    return self:globaldb(function(db)
        for _,path,_,_ in db:urows(SQL) do
            return path,true
        end

        return "",false
    end)
end

function module:query_sync(name,version)
    local SQL = string.format('SELECT * FROM _SYNC WHERE _NAME="%s" and _VERSION="%s"',name,version)

    return self:globaldb(function(db)
        for _,path,_,_,_ in db:urows(SQL) do
            return path,true
        end

        return "",false
    end)
end

function module:remove_install(name,version)
    local SQL = string.format('delete FROM _INSTALL WHERE _NAME="%s" and _VERSION="%s"',name,version)

    self:localdb(function(db)
        sqlexec(db,SQL)
    end)
end

function module:save_install(name,version,source,path,force)

    if force then
        self:remove_install(name,version)
    end

    local SQL = string.format('insert into _INSTALL VALUES("%s","%s","%s","%s","%s")',name,path,source,version,self.lake.GSMAKE_TARGET_HOST)

    self:localdb(function(db)
        sqlexec(db,SQL)
    end)

end

function module:remove_sync(name,version)
    local SQL = string.format('delete FROM _SYNC WHERE _NAME="%s" and _VERSION="%s"',name,version)

    self:globaldb(function(db)
        sqlexec(db,SQL)
    end)
end

function module:save_sync(name,version,source,path,sync,force)

    if force then
        self:remove_sync(name,version)
    end

    local SQL = string.format('insert into _SYNC VALUES("%s","%s","%s","%s","%s")',name,path,source,version,sync)

    self:globaldb(function(db)
        sqlexec(db,SQL)
    end)

end

function module:remove_source(name,version)

    local SQL = string.format('delete FROM _SOURCE WHERE _NAME="%s" and _VERSION="%s"',name,version)

    self:globaldb(function(db)
        sqlexec(db,SQL)
    end)
end


function module:save_source(name,version,source,path,force)

    if force then
        self:remove_source(name,version)
    end

    local SQL = string.format('insert into _SOURCE VALUES("%s","%s","%s","%s",%d)',name,path,source,version,0)

    self:globaldb(function(db)
        sqlexec(db,SQL)
    end)

end

function module:cached_source(name,version,source,path)
    self:remove_source(name,version)
    local SQL = string.format('insert into _SOURCE VALUES("%s","%s","%s","%s",%d)',name,path,source,version,1)

    self:globaldb(function(db)
        sqlexec(db,SQL)
    end)
end

function module:list_cached(f)
    local SQL = 'SELECT * FROM _SOURCE WHERE _CACHED=1'

    self:globaldb(function(db)
        for name,path,_,version,_ in db:urows(SQL) do
            f(name,path,version)
        end
    end)
end

return module

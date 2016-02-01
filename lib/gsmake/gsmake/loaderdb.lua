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

function module.ctor (loader,path)

    local obj = {
        Loader          = loader                            ;
        Path            = path                              ; -- the global package cached repo path
        dbPath          = filepath.join(path,"loader.db")     ; -- database fullpath
    }

    module.exec(obj,function(db)
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

    return obj
end

function module:exec (f)

    local db = assert(sqlite3.open(self.dbPath))

    local result = { f(db) }

    db:close()

    return table.unpack(result)
end

return module

return {
    GSMAKE_FILE                 = ".gsmake.lua"                         ;
    GSMAKE_TMP_DIR              = ".gsmake"                             ;
    GSMAKE_ENV                  = "GSMAKE_HOME"                         ;
    GSMAKE_DEFAULT_VERSION      = "snapshot"                            ;
    GSMAKE_TARGET_HOST          = require "lemoon.sys" .host()          ;
    GSMAKE_TARGET_ARCH          = require "lemoon.sys" .arch()          ;
    GSMAKE_SKIP_DIRS            = { ".gsmake",".git", ".svn" }          ;
}

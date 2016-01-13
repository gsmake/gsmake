return {
    ["github.com"] = {

        Sync = "git",

        URL = [=[https://$1.git]=],

        Pattern = [=[^(github\.com/[A-Za-z0-9_\.\\-]+/[A-Za-z0-9_\.\\-]+)(/[A-Za-z0-9_\.\\-]+)*$]=]
    };
}
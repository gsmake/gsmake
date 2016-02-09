return {
    ["github.com"] = {

        Downloader = { name = "github.com/gsmake/git" },

        URL = [=[https://$1.git]=],

        Pattern = [=[^(github\.com/[A-Za-z0-9_\.\\-]+/[A-Za-z0-9_\.\\-]+)(/[A-Za-z0-9_\.\\-]+)*$]=]
    };
}

local fs        = require "lemoon.fs"
local sys       = require "lemoon.sys"
local class     = require "lemoon.class"
local filepath  = require "lemoon.filepath"

local logger    = class.new("lemoon.log","lake")

local module = {}

function module.ctor(task)
    logger:I("check the cmake command line tools ...")
    local ok, path = sys.lookup("cmake")

    if not ok then
        error("check the cmake command line tools -- failed, not found")
    end

    logger:D("cmake tool path :%s",path)

    logger:I("check the cmake command line tools -- success")

    local obj = {
        cmake_path           = path;
        task                 = task;
        cmake_output_dir     = filepath.join(task.Owner.Lake.Config.GSMAKE_INSTALL_PATH,"cmake");
        projects             = {};
        test_projects        = {};
    }

    return obj
end

function module:create_projects(name,config)
    logger:D("found clang module [%s]",name)

    local lake                  = self.task.Lake

    local module_type           = config["type"]
    local module_cmakeconfig    = config["config"]
    local module_skip_dirs      = config["skips"]
    local module_src            = config["src"]
    local module_test           = config["test"]
    local module_header_files   = config["header"]
    local module_source_files   = config["source"]
    local module_dependencies   = config["dependencies"]

    -- check and set default values

    if module_type == nil then
        module_type = lake.Config.GSMAKE_CLANG_DEFAULT_TYPE or "static"
    end

    if module_cmakeconfig == nil then
        module_cmakeconfig = "config.cmake"
    end

    if module_skip_dirs == nil then
        module_skip_dirs = lake.Config.GSMAKE_SKIP_DIRS
    end

    if module_src == nil then
        module_src =  "src/main/cpp"
    end

    if module_test == nil then
        module_test = "src/test/cpp"
    end

    if module_header_files == nil then
        module_header_files = { "*.h","*.hpp", "*.hxx","*.hh" }
    end

    if module_source_files == nil then
        module_source_files = { "*.c","*.cpp","*.cxx","*.cc" }
    end

    local project = class.new("project",lake,name,{
        CMAKE_OUTPUT_DIR            = self.cmake_output_dir;
        CMAKE_CONFIG_FILE_NAME      = module_cmakeconfig;
        CMAKE_HEADER_FILES          = module_header_files;
        CMAKE_SOURCE_FILES          = module_source_files;
        CMAKE_SKIP_DIRS             = module_skip_dirs;
        Dir                         = filepath.join(self.task.Owner.Path,name,module_src);
        Dependencies                = module_dependencies;
    })

    self.projects[name] = project

    if module_type ~= "exe" then
        local test_project = class.new("project",lake,name .. "-test",{
            CMAKE_OUTPUT_DIR            = self.cmake_output_dir;
            CMAKE_CONFIG_FILE_NAME      = module_cmakeconfig;
            CMAKE_HEADER_FILES          = module_header_files;
            CMAKE_SOURCE_FILES          = module_source_files;
            CMAKE_SKIP_DIRS             = module_skip_dirs;
            Dir                         = filepath.join(self.task.Owner.Path,name,module_test);
            Dependencies                = config["test_dependencies"];
        })

        self.test_projects[name] = test_project
    end

end

function module:gen()

    local task = self.task

    if not fs.exists(self.cmake_output_dir) then
        fs.mkdir(self.cmake_output_dir,true)
    end

    local cmake_file_path = filepath.join(self.cmake_output_dir,"CMakeLists.txt")
    logger:I("generate cmake file\n\t%s",cmake_file_path)

    local f = assert(io.open(cmake_file_path,"w+"))

    f:write(class.new("lemoon.tpl","cmake"):gen({
        name = filepath.base(task.Owner.Name);
    }))

    f:close()

    logger:I("generate cmake file -- success")
end

function module:run()
    logger:I("run cmake-gen for package %s ...",self.task.Owner.Path)

    local clang = self.task.Owner.Properties.clang

    if clang == nil then
        logger:W("clang config not found !!!!")
    end

    for k,v in pairs(clang) do
        self:create_projects(k,v)
    end

    for _,project in pairs(self.projects) do
        project:link(self.projects)
    end
    for _,project in pairs(self.test_projects) do
        project:link(self.projects)
    end

    self:gen()

    logger:I("run cmake-gen for package %s -- success",self.task.Owner.Path)
end

return module

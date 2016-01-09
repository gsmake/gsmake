local fs        = require "lemoon.fs"
local sys       = require "lemoon.sys"
local class     = require "lemoon.class"
local filepath  = require "lemoon.filepath"

local logger    = class.new("lemoon.log","lake")

local module = {}
-- create new cmake plugin executor
function module.ctor (task)
    logger:I("check the cmake command line tools ...")
    local ok, path = sys.lookup("cmake")

    if not ok then
        error("check the cmake command line tools -- failed, not found")
    end

    logger:D("cmake tool path :%s",path)

    logger:I("check the cmake command line tools -- success")

    local obj = {
        cmake           = path;             -- the cmake execute full path
        task            = task;             -- cmake executor bind task
        owner           = task.Owner;       -- cmake executor owner package
        package         = task.Package;     -- cmake executor src package
        projects        = {};               -- clang projects
        tests           = {};               -- clang test projects
        cmakedir        = filepath.join(task.Owner.Lake.Config.GSMAKE_INSTALL_PATH,"cmake");
        outputdir       = filepath.toslash(task.Owner.Lake.Config.GSMAKE_INSTALL_PATH);
    }

    return obj
end

function module:loadproject (name, config)
    logger:D("found clang module [%s]",name)
    local lake = self.task.Lake
    if config["type"] == nil then
        config["type"] = lake.Config.GSMAKE_CLANG_DEFAULT_TYPE or "static"
    end

    if config["config"] == nil then
       config["config"] = "config.cmake"
    end

    if config["skips"] == nil then
       config["skips"] = lake.Config.GSMAKE_SKIP_DIRS
    end

    if config["src"] == nil then
        config["src"] =  { "src/main/cpp", "src/main/c", "src/main/oc","src/main/swift" }
    elseif type(config["src"]) == "string" then
        config["src"] = { config["src"] }
    end

    if config["test"] == nil then
        config["test"] =  { "src/test/cpp", "src/test/c", "src/test/oc","src/test/swift" }
    end

    if config["header_files"] == nil then
        config["header_files"] =  { "*.h","*.hpp", "*.hxx","*.hh" }
    end

    if config["source_files"] == nil then
        config["source_files"] =  { "*.c","*.cpp","*.cxx","*.cc" }
    end

    local srcDirs = {}

    for _,dir in ipairs(config["src"]) do
        table.insert(srcDirs,filepath.toslash(filepath.join(self.owner.Path,name,dir)));
    end

    local project = class.new("project",{
        Name                        = name;
        Type                        = config["type"];
        OutputDir                   = self.outputdir;
        SrcRootDir                  = filepath.toslash(filepath.join(self.owner.Path,name,"src/main"));
        SrcDirs                     = srcDirs;
        Deps                        = config["dependencies"] or {};
        lake                        = lake;
        config                      = config["config"];
        header_files                = config["header_files"];
        source_files                = config["source_files"];
        skips                       = config["skips"];
   })

   self.projects[name] = project

   if config["type"] ~= "exe" then
       local testDirs = {}

       for _,dir in ipairs(config["test"]) do
           table.insert(testDirs,filepath.toslash(filepath.join(self.owner.Path,name,dir)));
       end

       local project = class.new("project",{
           Name                        = name .. "-test";
           Type                        = "exe"; -- the test project's type is execute program
           OutputDir                   = self.outputdir;
           SrcRootDir                  = filepath.toslash(filepath.join(self.owner.Path,name,"src/test"));
           SrcDirs                     = testDirs;
           Deps                        = config["test_dependencies"] or {};
           lake                        = lake;
           config                      = config["config"];
           header_files                = config["header_files"];
           source_files                = config["source_files"];
           skips                       = config["skips"];
      })

      if #project.SrcFiles then
          self.tests[name] = project
      end
   end

end

function module:gen_cmake_files ()

    local task = self.task

    if not fs.exists(self.cmakedir) then
        fs.mkdir(self.cmakedir,true)
    end

    local codegen = class.new("lemoon.codegen")

    local template_dir = filepath.join(self.package.Path,"template")

    fs.list(template_dir,function (entry)
        if entry == "." or entry == ".." then
            return
        end

        local path = filepath.join(template_dir,entry)

        if fs.isdir(path) then
            return
        end

        local f =io.open(path)

        codegen:compile(filepath.base(path),f:read("a"))
    end)

    local cmake_root_dir = filepath.join(self.cmakedir,self.owner.Name)

    if not fs.exists(cmake_root_dir) then
        fs.mkdir(cmake_root_dir,true)
    end

    local cmake_root_file = filepath.join(cmake_root_dir,"CMakeLists.txt")

    codegen:render(cmake_root_file,"project.tpl",{
        name            = filepath.base(task.Owner.Name);
        projects        = self.projects;
        tests           = self.tests;
    })

    for _,project in pairs(self.projects) do
        local cmake_project_dir = filepath.join(cmake_root_dir,project.Name)
        if not fs.exists(cmake_project_dir) then
            fs.mkdir(cmake_project_dir,true)
        end
        local cmake_project_file = filepath.join(cmake_project_dir,"CMakeLists.txt")
        logger:I(cmake_project_file)
        codegen:render(cmake_project_file,"module.tpl",project)
    end


    for _,project in pairs(self.tests) do
        local cmake_project_dir = filepath.join(cmake_root_dir,project.Name)
        if not fs.exists(cmake_project_dir) then
            fs.mkdir(cmake_project_dir,true)
        end
        local cmake_project_file = filepath.join(cmake_project_dir,"CMakeLists.txt")
        logger:I(cmake_project_file)
        codegen:render(cmake_project_file,"module.tpl",project)
    end

    logger:I("generate cmake file -- success")
end

function module:run ()
    local clang = self.task.Owner.Properties.clang

    if clang == nil then
        logger:W("clang projects not found !!!!")
        return
    end

    for k,v in pairs(clang) do
        self:loadproject(k,v)
    end


    for _,project in pairs(self.projects) do
        project:link(self.projects)
    end

    for name,project in pairs(self.tests) do
        project:link(self.projects)
        logger:I("%s",self.projects[name])
        table.insert(project.Linked,self.projects[name])
    end

    -- generate cmake files
    self:gen_cmake_files()

    local cmake_build_dir = filepath.join(self.cmakedir,self.owner.Name,".build")

    if not fs.exists(cmake_build_dir) then
        fs.mkdir(cmake_build_dir,true)
    end

    local exec = sys.exec(self.cmake)
    exec:dir(cmake_build_dir)
    exec:start("..")
    exec:wait()

    exec:start("--build",".")
    exec:wait()
end

return module

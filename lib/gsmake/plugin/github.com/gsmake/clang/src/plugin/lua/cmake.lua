local fs        = require "lemoon.fs"
local sys       = require "lemoon.sys"
local throw     = require "lemoon.throw"
local class     = require "lemoon.class"
local filepath  = require "lemoon.filepath"

local logger    = class.new("lemoon.log","gsmake")
local console    = class.new("lemoon.log","console")

local module = {}
-- create new cmake plugin executor
function module.ctor (task)
    logger:I("check the cmake command line tools ...")
    local ok, cmake_path = sys.lookup("cmake")

    if not ok then
        throw("check the cmake command line tools -- failed, not found")
    end

    logger:D("cmake tool path :%s",cmake_path)

    local obj = {
        cmake_path      = cmake_path;       -- cmake path
        task            = task;             -- cmake executor bind task
        owner           = task.Owner;       -- cmake executor owner package
        package         = task.Package;     -- cmake executor src package
        projects        = {};               -- clang projects
        tests           = {};               -- clang test projects
    }

    loader = task.Owner.Loader

    obj.cmake_root_dir = filepath.join(
        loader.Temp,"cmake",
        loader.Config.TargetHost .. "-" .. loader.Config.TargetArch)

    obj.outputdir = filepath.toslash(filepath.join(
        loader.Temp,"clang",
        loader.Config.TargetHost .. "-" .. loader.Config.TargetArch))

    return obj
end

function module:loadproject (name, config)
    logger:D("found clang module [%s]",name)

    if config["type"] == nil then
        config["type"] = loader.Config.ClangModuleType or "static"
    end

    if type(config["type"]) == "function" then
        config["type"] = config["type"](self.task)
    end

    if config["config"] == nil then
       config["config"] = "config.cmake"
    end

    if config["skips"] == nil then
       config["skips"] = loader.Config.SkipDirs
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

    if config["path"] == nil then
        config["path"] = name
    end

    local srcDirs = {}
    local path = config["path"]

    for _,dir in ipairs(config["src"]) do
        table.insert(srcDirs,filepath.toslash(filepath.join(self.owner.Path,path,dir)));
    end


    local project = class.new("project",{
        Name                        = name;
        Type                        = config["type"];
        OutputDir                   = self.outputdir;
        SrcRootDir                  = filepath.toslash(filepath.join(self.owner.Path,path,"src/main"));
        SrcDirs                     = srcDirs;
        Deps                        = config["dependencies"] or {};
        Loader                      = loader;
        TargetHost                  = loader.Config.TargetHost;
        config                      = config["config"];
        header_files                = config["header_files"];
        source_files                = config["source_files"];
        skips                       = config["skips"];
   })

   self.projects[name] = project

   if config["type"] ~= "exe" then
       local testDirs = {}

       for _,dir in ipairs(config["test"]) do
           table.insert(testDirs,filepath.toslash(filepath.join(self.owner.Path,path,dir)));
       end

       local test = class.new("project",{
           Name                        = name .. "-test";
           Type                        = "exe"; -- the test project's type is execute program
           OutputDir                   = self.outputdir;
           SrcRootDir                  = filepath.toslash(filepath.join(self.owner.Path,path,"src/test"));
           SrcDirs                     = testDirs;
           Deps                        = config["test_dependencies"] or {};
           Loader                      = loader;
           TargetHost                  = loader.Config.TargetHost;
           config                      = config["config"];
           header_files                = config["header_files"];
           source_files                = config["source_files"];
           skips                       = config["skips"];
      })

      if #test.SrcFiles > 0 then
          self.tests[name] = test
      end
   end

end

function module:gen_cmake_files ()

    local task = self.task

    if not fs.exists(self.cmake_root_dir) then
        fs.mkdir(self.cmake_root_dir,true)
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

    local cmake_root_file = filepath.join(self.cmake_root_dir,"CMakeLists.txt")

    codegen:render(cmake_root_file,"project.tpl",{
        name                    = filepath.base(task.Owner.Name);
        external_include        = filepath.join(self.outputdir,"include");
        external_libs           = filepath.join(self.outputdir,"lib");
        projects                = self.projects;
        tests                   = self.tests;
        target_host             = loader.Config.TargetHost;
    })

    for _,project in pairs(self.projects) do
        local cmake_project_dir = filepath.join(self.cmake_root_dir,project.Name)
        if not fs.exists(cmake_project_dir) then
            fs.mkdir(cmake_project_dir,true)
        end
        local cmake_project_file = filepath.join(cmake_project_dir,"CMakeLists.txt")
        logger:I(cmake_project_file)

        codegen:render(cmake_project_file,"module.tpl",project)
    end


    for _,project in pairs(self.tests) do
        local cmake_project_dir = filepath.join(self.cmake_root_dir,project.Name)
        if not fs.exists(cmake_project_dir) then
            fs.mkdir(cmake_project_dir,true)
        end
        local cmake_project_file = filepath.join(cmake_project_dir,"CMakeLists.txt")
        logger:I(cmake_project_file)
        codegen:render(cmake_project_file,"module.tpl",project)
    end

    logger:I("generate cmake file -- success")
end

function module:cmakegen ()

    local clang = self.task.Owner.Properties.clang

    if clang == nil then
        logger:W("clang projects not found !!!!")
        console:W("clang projects not found !!!!")
        return true
    end

    for k,v in pairs(clang) do
        self:loadproject(k,v)
    end


    for _,project in pairs(self.projects) do
        project:link(self.projects)
    end

    for name,project in pairs(self.tests) do
        project:link(self.projects)
        table.insert(project.Linked,self.projects[name])
    end

    -- generate cmake files
    self:gen_cmake_files()

    local cmake_root_dir = self.cmake_root_dir

    local cmake_build_dir = filepath.join(cmake_root_dir,".build")
    if not fs.exists(cmake_build_dir) then
        fs.mkdir(cmake_build_dir,true)
    end

    local owner = self.task.Owner
    console:I("generate cmake project [%s:%s] ...",owner.Name,owner.Version)
    logger:I("generate cmake project [%s:%s] ...",owner.Name,owner.Version)

    local exec = sys.exec(self.cmake_path,function(msg)
        logger:I("%s",msg)
    end)
    exec:dir(cmake_build_dir)

    local config = loader.Config
    if config.TargetHost == "Windows" and config.TargetArch == "AMD64" then
        exec:start("-A","x64","..")
    else
        exec:start("..")

    end

    if 0 ~= exec:wait() then
        console:E("run cmake config -- failed")
        return true
    end

    console:I("generate cmake project [%s:%s] -- success",owner.Name,owner.Version)
    logger:I("generate cmake project [%s:%s] -- success",owner.Name,owner.Version)
end

function module:compile ()
    local cmake_root_dir = self.cmake_root_dir
    local cmake_build_dir = filepath.join(cmake_root_dir,".build")

    local owner = self.task.Owner
    console:I("build cmake project [%s:%s] ...",owner.Name,owner.Version)
    logger:I("build cmake project [%s:%s] ...",owner.Name,owner.Version)

    local exec = sys.exec(self.cmake_path,function(msg)
        logger:I("%s",msg)
    end)
    exec:dir(cmake_build_dir)

    local buildconfig = self.task.Owner.Loader.Config.BuildConfig
    local buildclear = self.task.Owner.Loader.Config.BuildClear

    local buildargs = {"--build","."}

    if buildconfig then
        table.insert(buildargs,"--config")
        table.insert(buildargs,buildconfig)
    end

    if buildclear then
        table.insert(buildargs,"--clean-first")
    end

    exec:start(table.unpack(buildargs))

    if 0 ~= exec:wait() then
        console:E("clang build -- failed")
        return true
    end

    local owner = self.task.Owner
    console:I("build cmake project [%s:%s] -- success",owner.Name,owner.Version)
    logger:I("build cmake project [%s:%s] -- success",owner.Name,owner.Version)
end

function module:install (install_path)

    if install_path == nil or install_path == "" then
        throw("expect install path arg")
    end

    install_path = fs.abs(install_path)

    for _,project in pairs(self.projects) do

        for _,srcDir in ipairs(project.SrcDirs) do

            for _,pattern in ipairs(project.header_files) do
                fs.match(srcDir,pattern,project.skips,function(path)
                    path = filepath.toslash(filepath.clean(path))
                    local target = path:gsub(srcDir,"")
                    target = filepath.join(install_path,"include",target)

                    local dir = filepath.dir(target)

                    if not fs.exists(dir) then
                        fs.mkdir(dir,true)
                    end

                    fs.copy_file(path,target,fs.update_existing)
                end)
            end
        end
        console:I("%s -- success",project.Name)
    end

    fs.list(self.outputdir,function(entry)
        if entry == "." or entry == ".." then
            return
        end
        fs.copy_dir(filepath.join(self.outputdir,entry),filepath.join(install_path,entry),fs.update_existing)
    end)

end

return module

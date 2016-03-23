cmake_minimum_required(VERSION 3.2)
set_property(GLOBAL PROPERTY USE_FOLDERS ON)

project(@{{name}})

@{{ if target_host == "Windows" then }}
foreach(flag_var CMAKE_C_FLAGS
        CMAKE_CXX_FLAGS CMAKE_C_FLAGS_DEBUG CMAKE_CXX_FLAGS_DEBUG
        CMAKE_C_FLAGS_RELEASE CMAKE_CXX_FLAGS_RELEASE CMAKE_C_FLAGS_MINSIZEREL
        CMAKE_CXX_FLAGS_MINSIZEREL CMAKE_C_FLAGS_RELWITHDEBINFO
        CMAKE_CXX_FLAGS_RELWITHDEBINFO)
    #string(REGEX REPLACE "/MD" "/MT" ${flag_var} "${${flag_var}}")
    #string(REGEX REPLACE "/MDd" "/MTd" ${flag_var} "${${flag_var}}")
    string(REGEX REPLACE "/W3" "/W4" ${flag_var} "${${flag_var}}")
endforeach(flag_var)
@{{ else }}
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++14")
@{{ end }}

include_directories(@{{external_include}})
link_directories(@{{external_libs}})

@{{ for _,project in pairs(projects or {}) do }}
@{{ if not project.External then }}
add_subdirectory(@{{project.Name}})
@{{ end }}
@{{ end }}

@{{ for _,project in pairs(tests or {}) do }}
add_subdirectory(@{{project.Name}})
@{{ end }}

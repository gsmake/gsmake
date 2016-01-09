cmake_minimum_required(VERSION 3.3)
set_property(GLOBAL PROPERTY USE_FOLDERS ON)

project(@{{name}})


@{{ for _,project in pairs(projects or {}) do }}
add_subdirectory(@{{project.Name}})
@{{ end }}

@{{ for _,project in pairs(tests or {}) do }}
add_subdirectory(@{{project.Name}})
@{{ end }}

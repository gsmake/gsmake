cmake_minimum_required(VERSION 3.3)
project(@{{name}})


@{{ for _,project in pairs(projects) do }}
add_subdirectory(@{{project.Name}})
@{{ end }}

@{{ for _,project in pairs(test_projects) do }}
add_subdirectory(@{{project.Name}})
@{{ end }}

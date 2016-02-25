@{{for _,path in ipairs(ConfigFiles) do}}
include(@{{path}})

@{{ end }}

include_directories(
@{{ for _,src in ipairs(SrcDirs) do }}
@{{src}}

@{{ end }}

@{{ for _,dep in ipairs(Linked) do }}
@{{ if not dep.External then }}
@{{ for _,src in ipairs(dep.SrcDirs) do }}
@{{src}}

@{{ end }}
@{{ end }}
@{{ end }}
)

set(
header_files

@{{ for _,src in ipairs(HeaderFiles) do }}
@{{src}}

@{{ end }}
)

set(
src_files

@{{ for _,src in ipairs(SrcFiles) do }}
@{{src}}

@{{ end }}
)

foreach(FILE ${header_files})
    get_filename_component(FILE_NAME ${FILE} NAME)
    string(REPLACE ${FILE_NAME} "" DIRECTORY ${FILE})

    file(RELATIVE_PATH DIRECTORY @{{SrcRootDir}} ${DIRECTORY})

    file(TO_NATIVE_PATH "${DIRECTORY}" DIRECTORY)

    source_group("include\\${DIRECTORY}" FILES ${FILE})
endforeach()

foreach(FILE ${src_files})
    get_filename_component(FILE_NAME ${FILE} NAME)
    string(REPLACE ${FILE_NAME} "" DIRECTORY ${FILE})

    file(RELATIVE_PATH DIRECTORY @{{SrcRootDir}} ${DIRECTORY})

    file(TO_NATIVE_PATH "${DIRECTORY}" DIRECTORY)

    source_group("sources\\${DIRECTORY}" FILES ${FILE})
endforeach()

@{{ if Type == "exe" then }}
@{{ include(exe.tpl) }}
@{{ elseif Type == "win32" then }}
@{{ include(win32.tpl) }}
@{{ elseif Type == "static" then }}
@{{ include(static.tpl) }}
@{{ else }}
@{{ include(shared.tpl) }}
@{{ end }}


@{{if #Linked then}}
target_link_libraries(
@{{Name}}

@{{ for _,dep in ipairs(Linked) do }}
@{{dep.Name}}

@{{ end }}

@{{ if TargetHost == "Linux" then}}
pthread dl
@{{end}}

)
@{{ end }}


set_target_properties(
        @{{Name}}
        PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY @{{OutputDir}}/bin/
        RUNTIME_OUTPUT_DIRECTORY_DEBUG @{{OutputDir}}/bin/
        RUNTIME_OUTPUT_DIRECTORY_RELEASE @{{OutputDir}}/bin/)

set_target_properties(
        @{{Name}}
        PROPERTIES
        ARCHIVE_OUTPUT_DIRECTORY  @{{OutputDir}}/lib/
        ARCHIVE_OUTPUT_DIRECTORY_DEBUG @{{OutputDir}}/lib/
        ARCHIVE_OUTPUT_DIRECTORY_RELEASE @{{OutputDir}}/lib/)
set_target_properties(
        @{{Name}}
        PROPERTIES
        LIBRARY_OUTPUT_DIRECTORY  @{{OutputDir}}/lib/
        LIBRARY_OUTPUT_DIRECTORY_DEBUG @{{OutputDir}}/lib/
        LIBRARY_OUTPUT_DIRECTORY_RELEASE @{{OutputDir}}/lib/)

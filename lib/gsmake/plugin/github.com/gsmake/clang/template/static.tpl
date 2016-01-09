include_directories(@{{Dir}})

add_library(@{{Name}}

@{{ for _,src in ipairs(SrcFiles) do }}
@{{src}}

@{{ end }}
)

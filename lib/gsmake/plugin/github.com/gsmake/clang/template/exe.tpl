add_executable(@{{Name}}

@{{ for _,src in ipairs(SrcFiles) do }}
@{{src}}

@{{ end }}
)

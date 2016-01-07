@{{ if Type == "exe" then }}
@{{ include(exe.tpl) }}
@{{ elseif Type == "static" then }}
@{{ include(static.tpl) }}
@{{ else }}
@{{ include(shared.tpl) }}
@{{ end }}

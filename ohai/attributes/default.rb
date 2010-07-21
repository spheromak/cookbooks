
set_unless[:ohai][:plugin_path] = "/etc/ohai/plugins"

set_unless[:ohai][:plugins] =  [
    "xenserver.rb"
]

# minimal defaults for the main postfix setup
# by defaul postfix will be a null client setup 
# to forward to sysmail only.

default[:postfix][:conf][:html_directory]    = "no"
default[:postfix][:conf][:inet_interfaces]   = "localhost"
default[:postfix][:conf][:mail_owner]        = "postfix"
default[:postfix][:conf][:mydestination]     = nil
#default[:postfix][:conf][:mydomain]	        = "changeme"
#set[:postfix][:conf][:relayhost]         = ""
default[:postfix][:conf][:setgid_group]      = "postdrop"
default[:postfix][:conf][:local_transport]          = "error:5.1.1 Mailbox unavailable"
default[:postfix][:conf][:master_service_disable]   = "inet"

default[:postfix][:conf][:command_directory] = "/usr/sbin"
default[:postfix][:conf][:config_directory]  = "/etc/postfix"
default[:postfix][:conf][:daemon_directory]  = "/usr/libexec/postfix"
default[:postfix][:conf][:data_directory]    = "/var/lib/postfix"

default[:postfix][:conf][:myhostname]        = hostname 




#
# DEBUGGING CONTROL
#
# The debug_peer_level parameter specifies the increment in verbose
# logging level when an SMTP client or server host name or address
# matches a pattern in the debug_peer_list parameter.
#
# The debug_peer_list parameter specifies an optional list of domain
# or network patterns, /file/name patterns or type:name tables. When
# an SMTP client or server host name or address matches a pattern,
# increase the verbose logging level by the amount specified in the
# debug_peer_level parameter.
#
# The debugger_command specifies the external command that is executed
# when a Postfix daemon program is run with the -D option.
#

# you would never set these globally. probly only for a role in json or 
# for a single host I've only included it here for an example
#
#set_unless[:postfix][:debug][:debug_peer_level] = 5
#set_unless[:postfix][:debug][:debug_peer_list]  = "yahoo.com" 
# this debug command spawns the debber in screen  (whee)
#set_unless[:postfix][:debug][:debugger_command] = " PATH=/bin:/usr/bin:/sbin:/usr/sbin; export PATH; screen -dmS $process_name gdb $daemon_directory/$process_name $process_id & sleep 1"


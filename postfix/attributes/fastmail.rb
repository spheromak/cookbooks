# 
# FastMail Specific attributes.
# 

# only if we are called by FastMail Role 
#   postfix::multi shouldn't be called directly only by a Role. 
#  
if role?("mail_fastmail")

  # fastmail servers should enable mem FS mount
  set[:postfix][:multi]["postfix-fastmail"]["memqueue"] = "50"

  # enable dbg
  #set[:postfix][:debug][:debug_peer_level] = 5
  #set[:postfix][:debug][:debug_peer_list]  = "foo.com" 
  # this debug command spawns the debugger in screen  (whee)
  #set[:postfix][:debug][:debugger_command] = " PATH=/bin:/usr/bin:/sbin:/usr/sbin; export PATH; screen -dmS $process_name gdb $daemon_directory/$process_name $process_id & sleep 1"
end


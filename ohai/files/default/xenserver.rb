#-------------------------------------------------------------------------------
#
# Plugin to extend the virtualization attributes in a Xen Host
#
#-------------------------------------------------------------------------------

require_plugin 'virtualization'
require_plugin "#{os}::hostname"

provides 'xenserver'


# run std popen4 and return array of lines
def xe_open(cmd)
  a = Array.new
  popen4(cmd) do |pid, stdin, stdout, stderr|
    stdin.close
    stdout.each {|line| a << line.chomp}
  end
  return a
end

# return uuid from name
def xe_get_host_uuid(name) 
  xe_open("xe host-list name-label=#{name}").each do |line|
    if line =~ /uuid.*:\s(.*)$/
      return  $1
    end
  end
end

# return array of uuid's of vms resident on host
def xe_get_resident_vms(uuid)
  vms = Array.new
  xe_open("xe vm-list resident-on=#{uuid}").each do |line|
    if line =~ /uuid.*:\s(.*)$/
      vms << $1
    end
  end
  return vms
end

# return hash of param => values for vm 
def xe_get_params(cmd)
  h = Hash.new
  invalid_keys = %w/last-boot-record 
                    other-config other 
                    software-version 
                    other
                    platform
                    cpu_info 
                    license-server 
                    recommendations /

  xe_open(cmd).each do |line|
    if line.match(/\s(.*)\s\(.*\):\s(.*)/)
      k = $1.strip
      v = $2.strip
      k.gsub!(/{|}|<|>|\[|\]|(|)|'|"/,'')
      next if invalid_keys.include?(k)
      k.strip!
      v.gsub!(/<|>|\[|\]|(|)|\'|\"/,'')
      v=v.split(/;/) if v.match(/;/)
      v.to_s.each_line do |j|
        j.strip!
        if j.match(/([^:]*):(.*)/)
          # we have values that may be  foo:bar that we need to sepparate into more k/v
          k2 = $1.strip
	        next if invalid_keys.include?(k2)
          v2 = $2
          v2.strip!
          h.merge!({ k => { k2 => v2 }})
        else 
          h[k] =  v
        end
      end

      h.rehash
    end
  end
  return h
end


if not virtualization.nil? and virtualization[:role] == 'host'
  # create a guest_list attributte listing all the guests running
  emu = :system
  emu = :emulator if virtualization.has_key?(:emulator) 
  
  if virtualization[emu] == 'xen'
    virtualization[:guests] = Mash.new
    host_uuid = xe_get_host_uuid(hostname)
    virtualization[:uuid] = host_uuid
    xe_get_resident_vms(host_uuid).each do |vm|
      virtualization[:guests][vm] = xe_get_params("xe vm-param-list uuid=#{vm}")
    end
    virtualization[:xenserver] = xe_get_params("xe host-param-list uuid=#{host_uuid}")
    virtualization[:xenserver][:pool] = xe_get_params("xe  pool-list")
  end
end


# Plugin to extend the virtualization attributes in a Xen Host
require_plugin 'virtualization'
provides 'xenserver'

@xe_debug=false

# run std popen4 and return array of lines
def xe_open(cmd)
  a = Array.new
  puts "execute: #{cmd}" if @xe_debug
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
      puts "got uuid #{$1}" if @xe_debug
      return  $1
    end
  end
end

# return array of uuid's of vms resident on host
def xe_get_resident_vms(uuid)
  vms = Array.new
  xe_open("xe vm-list resident-on=#{uuid}").each do |line|
    if line =~ /uuid.*:\s(.*)$/
      puts "got vm: #{$1}" if @xe_debug
      vms << $1
    end
  end
  return vms
end

# return hash of param => values for vm 
def xe_get_vm_params(uuid)
  h = Hash.new
  xe_open("xe vm-param-list uuid=#{uuid}").each do |line|
    if line.match(/\s(.*)\s\(.*\):\s(.*)/)
      k = $1.strip
      v = $2.strip
      v=v.split(/;/) if v.match(/;/)
      puts "k-> #{k}" if @xe_debug
      h[k] =  v
      h.rehash
    end
  end
  return h
end

if not virtualization.nil? and virtualization[:role] == 'host'
  # create a guest_list attributte listing all the guests running
  if virtualization[:emulator] == 'xen'
    virtualization[:guests] = Mash.new
    host_uuid = xe_get_host_uuid(hostname)
    virtualization[:uuid] = host_uuid
    xe_get_resident_vms(host_uuid).each do |vm|
      virtualization[:guests][vm] = xe_get_vm_params(vm)
    end
  else
    puts "not a xen host" if @xe_debug
  end
end


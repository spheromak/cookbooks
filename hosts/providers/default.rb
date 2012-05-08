# Cookbook Name:: hosts
# Provider:: hosts
# Author:: Jesse Nelson <spheromak@gmail.com>
#
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

def initialize(new_resource, run_context)
  super(new_resource, run_context)
  @hosts_exits = false
  @orig_file = String.new
end

#
# assume that 1 ip per entrie and its unique
# hosts files typically honor the last entry for an ip, and we do the same here
#
def load_current_resource
  file = ::File.open("/etc/hosts", "r")
  file.each_line do |line|
    @orig_file << line
    line.chomp!
    data = line.split
    if data[0] == @new_resource.ip
      @hosts_exists = true
      @entries =  data.slice(1..-1)
    end
  end
  file.close
end

def cast_entries
  if @new_resource.entries.class == String
    @new_resource.entries
  else
    @new_resource.entries.join(" ")
  end
end
 
action :create do
  new_hosts = String.new
  # if they differ then were gonna rewrite
  if not same_entry 
    @orig_file.each_line do |line|
      data = line.split
      # current line = new resource (to be rewritten)
      if data[0] == @new_resource.ip
        new_hosts << "#{@new_resource.ip} #{cast_entries}\n"       
        next
      end
      new_hosts << line
    end   
  
    # if we didn't have a match but we wnat the new entry
    unless @hosts_exists
      new_hosts << "#{@new_resource.ip} #{cast_entries}\n"       
    end

    # create the file
    write_hosts(new_hosts)
    @new_resource.updated_by_last_action(true) 
  end
  
end


action :remove do
  new_hosts = ""
  # exists and is this resource
  # must be an exact match unless were asked to force it
  if same_entry || @new_resource.force == true
    @orig_file.each_line do |line|
      data = line.split
      # skip it if were removing
      next if data[0] == @new_resource.ip
      new_hosts << line
    end
    write_hosts(new_hosts)
    @new_resource.updated_by_last_action(true)
  end
end

# return true/false if new entries and parsed match up
# true  = equalty
# false = different
def same_entry
  # only if we found the ip in the first place
  # cause if we didn't then 
  if @hosts_exists 
    # we care about order here so if these things dont match force a rewrite/order
    # make sure we are comparing the same type
    return @entries.join(" ") == cast_entries
  end 
  false
end

def write_hosts(data)
  file "/etc/hosts" do 
    owner "root"
    mode "0644"
    content data
  end
end

#
# Cookbook Name:: network
# Recipe:: default
# Author:: jesse nelson <spheromak@gmail.com>
#
#

# get the databag item
# if there is no config for this node then nothing to do
#
# sorta sucks that data_bag_item  crits if it doesn't exist
#
#net_dbag = search(:network, "id:#{@node[:hostname]}" ).first

begin
    net_dbag = data_bag_item('network', @node[:hostname] ) 
rescue
    net_dbag = nil
end

if net_dbag 
  net_dbag['interfaces'].each_value do |int|
    ifconfig  int['ip'] do 
      ignore_failure  true 
      device  int['dev'] 
      mask    int['mask']  
      gateway int['gateway'] if int['gateway'] 
      mtu     int['mtu'] if int['mtu'] 
    end
  end
  
  # custom routes  well do dbag routes first here and then 
  # attrib based routes as well
  #
  net_dbag['routes'].each_value do |r|
    route r['network'] do 
      ignore_failure true
      gateway r['gateway']
      netmask  r['netmask'] if r['netmask']
      device   r['device']  if r['device']
    end
  end
end


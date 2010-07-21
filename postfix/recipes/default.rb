#
# Cookbook Name:: postfix
# Recipe:: default
# Author:: Jesse Nelson <spheromak@gmail.com>
#
#

package "sendmail" do  
    action :remove 
end


package "postfix" do
    action :install
end


service "postfix" do
    action   [ :enable, :start ]
    ignore_failure true
    supports :status => true, :restart => true, :reload => true
end


directory "/etc/mail" do
    owner  "root"
    group  "root"
    mode   "0755"
    action :create
end 

# setup file limits
remote_file "/etc/security/limits.d/postfix-limits.conf" do
    source "postfix-limits.conf"
end

link "/etc/aliases.db" do
    to "/etc/postfix/aliases.db"
end




# ensure perms on the lock (had issues with upgrades)
file  "/var/lib/postfix/master.lock" do
    mode "600"
    owner "postfix"
    group "postfix"
end 


# null exec for rebuilding transport db
execute "transport.map" do
    command "/usr/sbin/postmap /etc/postfix/transport" 
    action :nothing
    notifies :reload, resources(:service => "postfix")
end

# exec to rebuild virt tables
execute "virtual.map" do
    command "/usr/sbin/postmap /etc/postfix/virtual" 
    action :nothing
    notifies :reload, resources(:service => "postfix")
end

if @node[:postfix][:virtual]
  template "/etc/postfix/virtual" do
      source  "virtual_map.erb"
      mode    "0644"
      notifies :run, resources(:execute => "virtual.map")
  end
end

#
# default instance stuff 
#    every box will always have a default instance for doing sending
#    then each instance ontop of that (sysmail fastmail)
#    its the way postfix reccomends for postmulti-compat.
#
%w{main master}.each do |cfg|
    template "/etc/postfix/#{cfg}.cf" do
        source "#{cfg}.cf.erb"
        mode "644"
        variables(:postconf => @node[:postfix][:conf].sort)
    end
end


if @node[:postfix][:transports]
# build transports file 
    template "/etc/postfix/transport" do
        source "map.erb"
        mode   "644"
        variables(:map => @node[:postfix][:transports].sort)
        notifies :run, resources(:execute => "transport.map")
    end
end


#
# canonical maps based on env
#
execute "canonical.map" do
    command "/usr/sbin/postmap /etc/postfix/canonical" 
    action :nothing
    notifies :reload, resources(:service => "postfix")
end

if @node[:postfix][:canonical]
    template "/etc/postfix/canonical" do
        source "map.erb"
        mode   "644"
        variables(:map => @node[:postfix][:canonical].sort)
        notifies :run, resources(:execute => "canonical.map")
    end
end
     




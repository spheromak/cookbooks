#
# Cookbook Name:: ohai
# Recipe:: default
# Author:: Jesse Nelson <spheromak@gmail.com>

directory node[:ohai][:plugin_path] do
    owner "chef"
    recursive true
end

ruby_block "reload_client_config" do
  block do
    Chef::Config.from_file("/etc/chef/client.rb")
  end
    action :nothing
end



if node[:ohai].key?(:plugins)
  node[:ohai][:plugins].each do |plugin|
    remote_file node[:ohai][:plugin_path] +"/#{plugin}" do
      source plugin
      owner "chef"
      notifies :create, resources(:ruby_block => "reload_client_config")
    end
  end
end

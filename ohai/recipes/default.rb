#
# Cookbook Name:: ohai
# Recipe:: default
# Author:: Jesse Nelson <spheromak@gmail.com>

directory node[:ohai][:plugin_path] do
    owner "chef"
    recursive true
end

if node.ohai.attribute?(:plugins)
  node[:ohai][:plugins].each do |plugin|
    remote_file node[:ohai][:plugin_path] +"/#{plugin}" do
      source plugin
      owner "chef"
    end
  end
end

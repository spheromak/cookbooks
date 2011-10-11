# Cookbook Name:: hosts
# Recipe:: example
# Author:: Jesse Nelson <spheromak@gmail.com>
#

hosts "127.0.0.2" do
  entries %w/testlocal localtest test.localdomain.com/
end

hosts "127.0.0.3" do
  entries "testsingle"
end

hosts "127.0.0.4" do
  entries  ["another", "test" ]
end

hosts "127.1.1.3" do
  action :remove
  force  true
end


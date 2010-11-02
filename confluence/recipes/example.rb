#
# Cookbook Name:: confluence
# Recipe:: example
#
#


wiki "Example Page" do
  content out = "Generated from #{@cookbook_name} by chef contents will be overwritten"
  page_id "123456"
  url  "http://wiki.mydom.com"
  user "someuser"
  pass "somepass"
  space "somespace"
  parent_id "23456"
end


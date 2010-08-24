#
# Cookbook Name:: inventory
# Recipe:: wiki
#
#  this should only run on a single host. 
#
#


out = "Generated from #{@cookbook_name} by chef contents will be overwritten\n{toc}\n"


search(:node, "dmi:system") .sort.each do |h| 
  out << "{table-plus:#{wiki_table_attribs}}\n"
  out << "||h5. #{h[:fqdn]}||    ||\n"
  h[:dmi][:system].entries.each { |e| out << "| #{e[0]}| #{e[1]}|\n" }
  out << " |Cpu Total| #{h[:cpu][:total]}|\n |Cpu Real| #{h[:cpu][:real]}|\n"
  out << "|Mem Total| #{h[:memory][:total]}|\n "
  out << "{table-plus}\n"
end


wiki "Host Inventory" do
  content out
  page_id node.inventory.page_id
  url  "http://wiki.mydom.com"
  user "someuser"
  pass "somepass"
  space "somespace"
end


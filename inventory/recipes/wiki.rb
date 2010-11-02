#
# Cookbook Name:: inventory
# Recipe:: wiki
#
#  this should only run on a single host. 
#
#

include_recipe "confluence::library"

out = "Generated from CookBook:#{@cookbook_name} on #{node.fqdn} by chef contents will be overwritten\n{section}\n {column:width=50%}\n"


search(:node, "dmi:system").sort {|a,b| a.fqdn <=> b.fqdn}.each do |h| 
  out << "{table-plus:#{wiki_table_attribs}}\n"
  out << "||h5. #{h[:fqdn]}||    ||\n"
  h[:dmi][:system].entries.each { |e| out << "| #{e[0]}| #{e[1]}|\n" }
  out << " |Cpu Total| #{h[:cpu][:total]}|\n |Cpu Real| #{h[:cpu][:real]}|\n"
  out << "|Mem Total| #{h[:memory][:total]}|\n "
  out << "{table-plus}\n"
end

out << "
{column}

{column:width=30%}

{panel}
{toc:style=none|indent=20px|printable=false}
{panel}

{column}
{section}\n"

wiki "Host Inventory" do
  content out
  page_id node.inventory.page_id
  parent_id node.inventory.parent_id if node.inventory.parent_id
  url  "http://wiki.mydom.com"
  user "someuser"
  pass "somepass"
  space "somespace"
end


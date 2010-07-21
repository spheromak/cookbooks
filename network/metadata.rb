maintainer       "Jesse Nelson"
maintainer_email "spheromak@gmail.com"
license          "Apache 2.0"
description      "Configur Network Interfaces"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.1"

%w{ redhat centos fedora xenserver }.each do |os|
    supports os
end



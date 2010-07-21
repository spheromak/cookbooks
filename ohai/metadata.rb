maintainer        "Jesse Nelson"
maintainer_email  "spheromak@gmail.com"
license           "Apache 2.0"
description       "manage ohai and ohai plugins"
version           "0.1"

%w{ ubuntu debian redhat centos fedora }.each do |os|
  supports os
end



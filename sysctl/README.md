DESCRIPTION
===========
Manage sysctl sysctl provider. 
Default recipe reads key value pairs from node attributes and esures the system state. 

NOTE: If you are getting this from the community site i've renamed it jn_sysctl, you will have to rename the cookbook to sysctl
__WARNING:__ The default behavior is to write out /etc/sysctl.conf, which if you don't have settings in chef means you can kill your existing config. 

Attributes
----------
* __sysctl__:  Hash of k/v pairs with sysctl settings.   

Sysctl LWRP
===========
Properties
----------
* __name__:  The key name. Defaults to the resource name i.e. sysctl "somevalue"
* __value__:  what to set this key to
* __save__: save the seting back to the node data (default: yes)

Actions
-------
* __:set__  Make sure the running state is set  (default)
* __:write__  Write the config file  (default)

Known Bugs 
----------
* only really tested on centos/rhat and Linux. YMMV on other platforms

Example Usage 
=============
LWRP
----
Ensure runing state, and write this key to sysctl.conf

    sysctl "kernel.sysrq" do 
       value 1
    end

__Check out__ [recipes/example.rb] [2] For more reciepe examples.


Attributes
----------
In a role or overide:

    {
      "sysctl": {
        "net.ipv4.tcp_window_scaling": 0
      }
    }


__Check out__ [attributes/example.rb] [1] For more attribute examples. 

Change Log
==========
* 1.1.0:  Adding in :write action support so that it writes /etc/sysctl 
* 1.0.2:  Initial public release

Author and Licsense
===================

__Author__ Jesse Nelson <spheromak@gmail.com>

Copyright 2011, Jesse Nelson

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.



[1]: https://github.com/spheromak/cookbooks/blob/master/sysctl/attributes/example.rb 
[2]: https://github.com/spheromak/cookbooks/blob/master/sysctl/recipes/example.rb 

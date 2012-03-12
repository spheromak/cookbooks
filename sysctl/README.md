DESCRIPTION
===========
Manage sysctl sysctl provider. 
Default recipe reads key value pairs from node attributes and esures the system state. 

Attributes
----------
* __sysctl__:  Hash of k/v pairs with sysctl settings.   

Sysctl LWRP
===========
Properties
----------
* __name__:  The key name. Defaults to the resource name  i.e. sysctl "somevalue"
* __value__:  what to set this keys value too
* __save__:  save the seting ala "sysctl -w"   Default: true

Known Bugs 
----------
* This provider will always write out on any platform thats not linux. Only really tested on Linux/OSX/Solaris.

Example Usage 
=============
LWRP
----

    sysctl "kernel.sysrq" do 
       value 1
    end

    # multi value keys
    sysctl "net.ipv4.tcp_rmem" do 
      value "8192 87380 8388608"
    end
    
    # don't write out 
    # this will  run "sysctl -n -w kernel.sysrq=1"  every chef run
    sysctl "kernel.sysrq" do 
      value 1
      save false
    end


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
* 1.0.2:    Initial public release

Author and Licsense
===================

__Author__ jesse nelson <spheromak@gmail.com>

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

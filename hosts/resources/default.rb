# Cookbook Name:: hosts
# Provider:: hosts
# Author:: Jesse Nelson <spheromak@gmail.com>
#
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

HOSTS_IP_REGEX = /\A(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)(?:\.(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)){3}\z/
 
attribute :entries, :kind_of => [ String, Array ]
attribute :ip,      :name_attribute => true,      :regex => HOSTS_IP_REGEX
attribute :force,   :kind_of => [ TrueClass, FalseClass ], :default => false

actions :create, :remove
def initialize(*args)
  super
  @action = :create
end


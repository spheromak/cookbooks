#
# Library:: Iscsi Provider
#
# Copyright 2010, Jesse Nelson <sphermak@gmail.com>
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

class Chef
  class Resource
    class Iscsi < Chef::Resource
      require 'socket'

      def initialize(name, run_context=nil)
        super
        @resource_name = :iscsi
        @action = :login
        @target = name
        @host   = nil
        @port   = 3260
        @user   = nil
        @pass   = nil
        @ip     = nil
        @opt    = nil
        @allowed_actions.push(:login, :logout, :scan, :rescan, :auto, :remove)
      end
      
      def target(arg=nil)
        set_or_return( :target, arg, :kind_of => String )
      end
     
      # why can't this be a hash? 
      def opt(arg=nil)
        set_or_return( :opt, arg, :kind_of => Array )
      end
      
      def port(arg=nil)
        set_or_return( :port, arg, :kind_of => [ Fixnum, String ])
      end
   
      def host(arg=nil)
        set_or_return( :host, arg, :kind_of => String )
      end
      alias server host
      
      def user(arg=nil)
        set_or_return( :user, arg, :kind_of => String )
      end
      
      def pass(arg=nil)
        set_or_return( :pass, arg, :kind_of => String )
      end
    
      # 
      # TODO: theres a better way to do this
      # 
      def ip(arg=nil)
        my_ip = ip_lookup(self.host)
        set_or_return( :ip, my_ip, :kind_of => String )
      end 
      
      private 
      def ip_lookup(hostname)
        ip = Socket.gethostbyname(hostname)[3]
        return "%d.%d.%d.%d" % [ip[0], ip[1], ip[2], ip[3]]
      end  

    end
  end

  class Provider 
    class Iscsi < Chef::Provider
      include Chef::Mixin::Command

      def load_current_resource
        unless ( @new_resource.target && (@new_resource.host || @new_resource.server) )
          raise Chef::Exceptions::Iscsi, "Iscsi resource must be provided with a Target and Host" 
        end
        
        # scan and setup all target options
        action_scan unless target_known
        @cur_settings = get_settings
        setup_auth
        @new_resource.opt.each { |k,v| target_update(k,v) } if @new_resource.opt
      end

      def action_auto
        target_update("node.startup", "automatic")
      end
      
      def action_scan 
        run_command({ :command => "iscsiadm -m discovery -t st -p #{@new_resource.host}:#{@new_resource.port}" })
      end

      def action_rescan
        run_command({ :command => "iscsiadm -m session --rescan ", :ignore_failure => true })
      end

      def action_logout
        if logged_in
          run_command({ :command => "iscsiadm -m node -T #{@new_resource.target} -p  #{@new_resource.ip}:#{@new_resource.port} --logout" })
          Chef::Log.info "Logged OUT of target #{@new_resource.target} on #{@new_resource.host}:#{@new_resource.port}"
          @new_resource.updated 
        end
      end

      def action_login
        unless logged_in
          run_command({ :command => "iscsiadm -m node -T #{@new_resource.target} -p #{@new_resource.ip}:#{@new_resource.port} --login" })
          Chef::Log.info "Logged IN to target #{@new_resource.target} on #{@new_resource.host}:#{@new_resource.port}"
          @new_resource.updated  = true
        end
      end

      # before we remove we should always logout
      def action_remove
        action_logout
        run_command({ :command => "iscsiadm -m node -T #{@new_resource.target} -p #{@new_resource.ip}:#{@new_resource.port} -o delete" })
        Chef::Log.info "Removed all records of #{@new_resource.target} on #{@new_resource.host}:#{@new_resource.port}"
        @new_resource.updated  = true
      end
      
      # see if were logged into a target already
      def logged_in
        # don't even bother if we have no data about the target 
        status, output, error_message = output_of_command("iscsiadm -m session -P 0", {}) 
        unless status.exitstatus == 0
          handle_command_failures(status, "STDOUT: #{output}\nSTDERR: #{error_message}")
        end 
       
        case output 
        when /#{@new_resource.ip}:.+#{@new_resource.target}/
          true
        end
      end    
  
      # do we even know anything about this target (is it already up on a scan)
      def target_known
        status, output, error_message = output_of_command("iscsiadm -m node -T #{@new_resource.target} -P0 #{@new_resource.ip}:#{@new_resource.port}" , {}) 

        # when we get a 255 its unknown 
        # if its 0 then we know it exists
        unless [0,255].include?(status.exitstatus)
          handle_command_failures(status, "STDOUT: #{output}\nSTDERR: #{error_message}")
        end 
        
        return true if status.exitstatus == 0
        return nil
      end
  
      #
      # for now we only do chap tho this could just take an arg.  
      def setup_auth
        if  @new_resource.user 
          target_update("node.session.auth.authmethod", "CHAP")
          target_update("node.session.auth.username", @new_resource.user)
          target_update("node.session.auth.password", @new_resource.pass)
        else
          target_update("node.session.auth.authmethod", "None") 
        end
      end

      def get_settings
        status, output, error_message = output_of_command("iscsiadm -m node -T #{@new_resource.target} -P0 #{@new_resource.ip}:#{@new_resource.port}" , {})
        unless status.exitstatus == 0
          handle_command_failures(status, "STDOUT: #{output}\nSTDERR: #{error_message}")
        end 
        
        settings = Hash.new
        output.each do |line|
          next if line.match(/^#|^\s+#/)
          k,v = line.split(/=/)
          k.strip!
          v.strip!
          settings[k] = v
        end
        settings 
      end

      # generic method to update any of the updatable records on a target
      def target_update(key, value)
        Chef::Log.debug "Got #{key}:#{value} Stored: #{@cur_settings[key]}"
        unless @cur_settings[key] == value
          run_command({ :command => "iscsiadm -m node -T #{@new_resource.target} -p #{@new_resource.ip}:#{@new_resource.port} -o update -n #{key} -v #{value}" })
          @new_resource.updated  = true
          Chef::Log.info "updated target #{@new_resource.target} settings: #{key} =  #{value}"
        end
      end
  
    end
  end
end

Chef::Platform.platforms[:default].merge!( :iscsi => Chef::Provider::Iscsi )


#
# Cookbook Name:: postfix
# Recipe:: multi
# Author:: Jesse Nelson <spheromak@gmail.com>
#

include_recipe "postfix"


# unsure latest 
# options doesn't work for yum right now "no good reason not too"
#  would love to be able to add options "--enablerepo xxx"
package "postfix" do
    action :upgrade
end


# pull some stuff from the network databag to populate local node attribs
# TODO: review how were doing all of this recipe
# check the role  (fastmail/mailhog) 
# pull interfaces
# set the variables
# pull vip ip's from dbag
# setup iptables varialbes
#

if node.run_list.roles.include?("mail_fastmail")
  # need to get the num for mh/fmXX names
  hostnum  = @node['hostname'].scan(/(\d+\.?\d*|\.\d+)/).to_s
  net_dbag = data_bag_item('network', @node[:hostname] ) 
  
  if net_dbag['interfaces']['sysmail'] and net_dbag['interfaces']['fastmail'] 

    @node[:postfix][:multi]["postfix-sysmail"]["conf"]  = {
      "inet_interfaces"   => "#{net_dbag['interfaces']['sysmail']['ip']}, #{net_dbag['interfaces']['sysmail-ext']['ip']}",
      "smtp_bind_address" => net_dbag['interfaces']['sysmail-ext']['ip'],
      "myhostname"        => "fm#{hostnum.to_i}-sys" }

    @node[:postfix][:multi]["postfix-fastmail"]["conf"] = {
      "inet_interfaces"   => "#{net_dbag['interfaces']['fastmail']['ip']}, #{net_dbag['interfaces']['fastmail-ext']['ip']}",
      "smtp_bind_address" => net_dbag['interfaces']['fastmail-ext']['ip'],
      "myhostname"        => "fm#{hostnum.to_i}" }


    # get sysmail vip ip
    # get fsastmail vip ip
    #  setup iptables
    fm_vip  = data_bag_item('services', 'fastmail')["vips"][0]["ip"]
    sys_vip = data_bag_item('services', 'sysmail')["vips"][0]["ip"]

    @node[:iptables][:vip] = {
      sys_vip => { 
        :ip => net_dbag['interfaces']['sysmail']['ip'], 
        :dport => "25" }, 
      fm_vip => { 
        :ip => net_dbag['interfaces']['fastmail']['ip'],  
        :dport => "25" } 
    }

  end
end

# multi instance stuff
if @node[:postfix][:multi]
    # mem fs is only on fastmail instance
    # enable postmulti
    execute "multi.init" do
        command "/usr/sbin/postmulti -e init && touch /etc/postfix/multi.enabled"
        creates "/etc/postfix/multi.enabled"
        action  :run
    end  

    # loop over all multi instances and asemble templates.
    postconf = Hash.new
    multidir = String.new 

    @node[:postfix][:multi].each do |instance, settings| 
        # should do some checking here the instance name has to always start with 
        # "postfix-" to be compatable 
        instance = instance.downcase 
        if instance !~ /^postfix-/ 
            Chef::Log.error("Instance '#{instance}' in posfix[:multi]  not 'postfix-' prefix, Skipping")
            next 
        end

        #  we can't have this setup b4 hand
        # so well re-gen after each run. this is a bit of a hack to make sure 
        # mult-instance support works.  
        if multidir.empty?
            multidir << "/etc/#{instance}" 
        else 
            multidir << ",/etc/#{instance}"
        end 
        @node[:postfix][:conf][:multi_instance_directories] = multidir
        Chef::Log.info("Instance Dirs: #{multidir}") 

        # set the instance atrribs 
        # this way we keep postmulti support even after we generated the instance's version
        # of main.cf  tho i dunno if this gets merged into settings here nor not. 
        # may want to make the hash merge against @node[..][instance][conf] instead of settings
        # if settings isn't a proper ref to @node .. should be tho.. 
        @node[:postfix][:multi][instance]['conf']['multi_instance_name'] = instance 
        @node[:postfix][:multi][instance]['conf']['config_directory']    = "/etc/#{instance}"
        @node[:postfix][:multi][instance]['conf']['data_directory']      = "/var/lib/#{instance}"
        @node[:postfix][:multi][instance]['conf']['queue_directory']     = "/var/spool/#{instance}"

        group = @node[:postfix][:multi][instance]['conf']['multi_instance_group'] || "mta" 
        execute "#{instance}.create" do
            command "postmulti -I #{instance} -G #{group} -e create -v"
            creates "/etc/#{instance}"
            action  :run
        end

        

        # convert postfix config into hash to merge instance's config into it. 
        postconf = @node[:postfix][:conf].to_hash.merge(@node[:postfix][:multi][instance]['conf'])
    
        execute "#{instance}.transport.map" do
            command "/usr/sbin/postmap /etc/#{instance}/transport"
            action :nothing
            notifies :reload, resources(:service => "postfix")
        end

        # TEMPLATES!  assseemmmmmbleee!!!        
        template "/etc/#{instance}/main.cf" do
            source "main.cf.erb"
            mode 0644
            notifies :restart, resources(:service => "postfix") 
            # so much pain here.. need to pass in an array. may as well sort it.
            #  could also use .to_a  to flatten this.
            variables(:postconf => postconf.sort)
        end

        # push transports
        instance_transports = Hash.new
        if @node[:postfix][:transports]
            if @node[:postfix][:multi][instance]['transports']
                instance_transports = @node[:postfix][:transports].to_hash.merge(@node[:postfix][:multi][instance]['transports']) 
            else 
                instance_transports = @node[:postfix][:transports].to_hash
            end 

            template "/etc/#{instance}/transport" do
                source "map.erb"
                mode "644"
                variables(:map => instance_transports.sort)
                notifies :run, resources(:execute => "#{instance}.transport.map")
            end

        end  

        # mount/create mem fs and restart instance if attribs say so      
        if  @node[:postfix][:multi][instance]['memqueue']
            
            # calculate the memfs size based on the % value from the attrib * 0.000001 to convrt form kB to G
            memfs_size = (@node[:memory][:total].to_i * 0.000001) * (@node[:postfix][:multi][instance]['memqueue'].to_i * 0.01)

            Chef::Log.info("TmpFS for #{instance}. 
                             ohai reports: #{@node[:memory][:total]} 
                       configured percent: #{@node[:postfix][:multi][instance]['memqueue']} 
                               calculated: #{memfs_size.to_i}gB")

            mount "/var/spool/#{instance}" do
                pass     0
                fstype   "tmpfs"
                device   "/dev/null"
                options  "nr_inodes=999k,mode=755,size=#{memfs_size.to_i}g"
                action   [:mount, :enable]
                notifies :restart, resources(:service => "postfix")
            end
        end

        instance_transports.clear 
        postconf.clear 
    end
end

# 
# this recipie is for a disabled postfix instance
#


service "postfix" do
    supports :status => true, :restart => true, :reload => true
    action   [:disable, :stop]
end


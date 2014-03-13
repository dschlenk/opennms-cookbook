# note that opennms needs to be running for provisioning commands to work 
# as they use the ReST interface. 
ruby_block "noop" do
  block do
   noop = 1
  end
  notifies :start, "service[opennms]", :immediately
end
# all options
opennms_import "saucy-source" do
  sync_import true
end

#minimal
opennms_import "dry-source" 

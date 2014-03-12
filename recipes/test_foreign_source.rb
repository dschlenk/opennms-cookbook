# note that opennms needs to be running for provisioning commands to work 
# as they use the ReST interface. 
ruby_block "noop" do
  block do
   noop = 1
  end
  notifies :start, "service[opennms]", :immediately
end
# all options
opennms_foreign_source "saucy-source" do
  scan_interval "7d"
end

#minimal
opennms_foreign_source "dry-source" 

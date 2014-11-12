# all options
opennms_disco_specific "10.10.1.1" do
  retry_count 13
  timeout 4000
end

# minimal, and probably more typical
opennms_disco_specific "10.10.1.2"

ruby_block "noop" do
  block do
   noop = 1
  end
  notifies :start, "service[opennms]", :immediately
end

opennms_foreign_source 'disco-specific-source'

# with foreign source
opennms_disco_specific "10.3.0.1" do
  foreign_source 'disco-specific-source'
end

# opennms_foreign_source 'bears'
# all options
opennms_disco_specific '10.10.1.1' do
  retry_count 13
  timeout 4000
  location 'Chicago'
  foreign_source 'bears'
end

# minimal, and probably more typical
opennms_disco_specific '10.10.1.2'

# opennms_foreign_source 'disco-specific-source'

# with location
opennms_disco_specific '10.3.0.2' do
  location 'Minneapolis'
end

opennms_disco_specific 'same IP different location' do
  ipaddr '10.3.0.2'
  timeout 4001
  location 'Milwaukee'
end

opennms_disco_specific 'same IP no location' do
  retry_count 13
  timeout 4000
  ipaddr '10.3.0.2'
end

# with location and foreign source
opennms_disco_specific '10.3.0.1' do
  location 'Detroit'
  foreign_source 'disco-specific-source'
end

opennms_disco_specific '127.0.0.1'

opennms_disco_specific 'update 127.0.0.1' do
  ipaddr '127.0.0.1'
  retry_count 14
  timeout 4001
  foreign_source 'bears'
  action :update
end

opennms_disco_specific '127.0.0.2'

opennms_disco_specific 'noop 127.0.0.2' do
  ipaddr '127.0.0.2'
  retry_count 14
  timeout 4001
  location 'St Louis'
  action :create_if_missing
end

opennms_disco_specific '127.0.0.3' do
  retry_count 15
  timeout 4002
  location 'St Louis Park'
end

opennms_disco_specific 'add 127.0.0.3 no location' do
  ipaddr '127.0.0.3'
end

opennms_disco_specific 'delete 127.0.0.3 St Louis Park' do
  ipaddr '127.0.0.3'
  location 'St Louis Park'
  action :delete
end

opennms_disco_specific 'delete non existing' do
  ipaddr '127.0.0.4'
  action :delete
end

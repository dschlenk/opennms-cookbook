# all options
opennms_disco_range 'anRange' do
  range_begin '10.0.0.1'
  range_end  '10.0.0.254'
  range_type 'include'
  location 'Detroit'
  foreign_source 'disco-source'
  retry_count 37
  timeout 6000
end

# all useful options for exclude
opennms_disco_range 'anotherRange' do
  location 'Detroit'
  range_begin '10.0.0.10'
  range_end '10.0.0.20'
  range_type 'exclude'
end

# minimal - defaults to range_type 'include'
opennms_disco_range 'anOtherRange' do
  range_begin '192.168.0.1'
  range_end '192.168.254.254'
end

# minimal with foreign source and location
opennms_disco_range 'anForeignSourceRange' do
  range_begin '10.1.0.1'
  range_end '10.1.0.254'
  location 'Detroit'
  foreign_source 'disco-source'
end

opennms_disco_range 'updateRange' do
  range_begin '10.2.0.1'
  range_end '10.2.0.10'
end

opennms_disco_range 'update updateRange' do
  range_begin '10.2.0.1'
  range_end '10.2.0.10'
  foreign_source 'ten-dot-two-dot-zero-dot-one-through-ten'
  retry_count 38
  timeout 6001
  action :update
end

opennms_disco_range 'implicit update updateRange' do
  range_begin '10.2.0.1'
  range_end '10.2.0.10'
  retry_count 39
end

opennms_disco_range 'noop update updateRange' do
  range_begin '10.2.0.1'
  range_end '10.2.0.10'
  timeout 6000
  action :create_if_missing
end

opennms_disco_range 'range to create and delete' do
  range_begin '10.5.0.1'
  range_end '10.6.0.1'
  range_type 'exclude'
  location 'Mars'
end

opennms_disco_range 'delete range to create and delete' do
  range_begin '10.5.0.1'
  range_end '10.6.0.1'
  range_type 'exclude'
  location 'Mars'
  action :delete
end

opennms_disco_range 'delete non-existant range with identity similar to existant range' do
  range_begin '10.2.0.1'
  range_end '10.2.0.10'
  location 'Mars'
  action :delete
end

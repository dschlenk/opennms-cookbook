# all options
opennms_disco_range "anRange" do
  range_begin '10.0.0.1' 
  range_end  '10.0.0.254'
  range_type 'include'  # can be 'include' or 'exclude'
  retry_count 37
  timeout 6000
end

# minimal
opennms_disco_range "anOtherRange" do
  range_begin '192.168.0.1'
  range_end '192.168.254.254'
  range_type 'exclude'
end

opennms_snmp_collection_group "wibble-wobble" do
  collection_name "baz"
  file "wibble-wobble.xml"
  system_def "Wibble"
  # while the schema let's you do both at the same time, it doesn't make sense
  # logically at least if I understand the use case properly.
  #exclude_filters ["Wobble"]
end

include_recipe 'opennms_resource_tests::snmp_config_profile'

opennms_snmp_config_profile 'foo' do
  action :delete
end

# only the properties involved in identity need be present
opennms_snmp_config_definition 'uses profile foo' do
  profile_label 'foo'
  action :delete
end

opennms_snmp_config_definition 'uses profile foo at location bar' do
  profile_label 'foo'
  location 'bar'
  action :delete
end

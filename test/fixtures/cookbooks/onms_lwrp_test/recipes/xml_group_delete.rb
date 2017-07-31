# frozen_string_literal: true
include_recipe 'onms_lwrp_test::xml_group'

# delete minimal
opennms_xml_group 'delete minimal' do
  group_name 'minimal'
  source_url 'http://{ipaddr}/get-minimal'
  collection_name 'foo'
  resource_xpath '/minimal/group'
  action :delete
  notifies :restart, 'service[opennms]', :delayed
end

# delete 'all options'
# note how only the name, source_url, collection, resource_xpath need to be populated
opennms_xml_group 'delete fxa-sc' do
  group_name 'fxa-sc'
  source_url 'http://{ipaddr}/group-example'
  collection_name 'foo'
  resource_xpath "/measCollecFile/measData/measInfo[@measInfoId='dns|dns']/measValue"
  action :delete
  notifies :restart, 'service[opennms]', :delayed
end

opennms_xml_group 'delete nothing' do
  group_name 'nope'
  source_url 'http://fictional.com/get-example'
  collection_name 'foo'
  resource_xpath '/xpath/to/the/danger/zone'
  action :delete
  notifies :restart, 'service[opennms]', :delayed
end

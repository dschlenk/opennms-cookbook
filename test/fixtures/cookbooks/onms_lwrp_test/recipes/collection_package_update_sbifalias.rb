# frozen_string_literal: true
include_recipe 'onms_lwrp_test::collection_package'
opennms_collection_package 'foo' do
  filter "IPADDR != '1.1.1.1' & categoryName == 'update_foo'"
  store_by_if_alias true
  notifies :restart, 'service[opennms]', :delayed
end

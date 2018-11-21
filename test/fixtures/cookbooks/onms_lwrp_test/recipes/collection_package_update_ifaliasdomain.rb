# frozen_string_literal: true
include_recipe 'onms_lwrp_test::collection_package'
opennms_collection_package 'foo' do
	filter "(IPADDR != '1.1.1.1') & (categoryName == 'update_foo')"
	remote true
  if_alias_domain 'updated_foo.com'
  action :create
  notifies :restart, 'service[opennms]', :delayed
end

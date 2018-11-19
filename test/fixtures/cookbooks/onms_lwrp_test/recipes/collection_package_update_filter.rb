# frozen_string_literal: true
include_recipe 'onms_lwrp_test::collection_package'
opennms_collection_package 'foo' do
  filter "(IPADDR != '0.0.0.0') & (categoryName == 'update_foo')"
  action :create
end

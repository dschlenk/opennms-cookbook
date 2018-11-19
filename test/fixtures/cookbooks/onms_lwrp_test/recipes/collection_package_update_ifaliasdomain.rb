# frozen_string_literal: true
include_recipe 'onms_lwrp_test::collection_package'
opennms_collection_package 'foo' do
  if_alias_domain 'updated_foo.com'
  action :create
end

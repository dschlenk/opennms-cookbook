# frozen_string_literal: true
include_recipe 'onms_lwrp_test::collection_package'
opennms_collection_package 'foo' do
  include_urls []
  action :create
end

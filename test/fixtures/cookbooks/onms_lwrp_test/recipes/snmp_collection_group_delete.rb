# frozen_string_literal: true
include_recipe 'onms_lwrp_test::snmp_collection_group'
opennms_snmp_collection_group 'group-name-to-delete' do
  collection_name 'collection-name-to-delete'
  action :delete
end

control 'group-name-tobe-delete' do
	action :delete
end
# frozen_string_literal: true
include_recipe 'onms_lwrp_test::import_node'

opennms_import_node 'delete nodeC' do
  foreign_source_name 'dry-source'
  foreign_id 'nodeC'
  action :delete
end

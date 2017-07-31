# frozen_string_literal: true
include_recipe 'onms_lwrp_test::import_node'

opennms_import_node 'delete nodeB' do
  foreign_source_name 'dry-source'
  foreign_id node_b_foreign_id
  action :delete
end

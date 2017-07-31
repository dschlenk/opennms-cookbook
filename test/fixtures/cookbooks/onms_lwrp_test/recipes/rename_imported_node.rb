# frozen_string_literal: true
include_recipe 'onms_lwrp_test::import_node'
opennms_import_node 'rename nodeC' do
  node_label 'node-c.example.net'
  foreign_source_name 'dry-source'
  foreign_id node_c_foreign_id
  sync_import true
end

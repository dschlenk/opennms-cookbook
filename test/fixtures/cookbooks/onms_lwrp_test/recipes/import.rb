# frozen_string_literal: true
include_recipe 'onms_lwrp_test::foreign_source'
# all options
opennms_import 'saucy-source' do
  foreign_source_name 'saucy-source'
  sync_import true
  sync_wait_periods 30
  sync_wait_secs 10
end

# minimal
opennms_import 'dry-source' do
  foreign_source_name 'dry-source'
end

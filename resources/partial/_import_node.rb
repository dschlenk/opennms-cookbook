include Opennms::Cookbook::Provision::ModelImportHttpRequest
include Opennms::XmlHelper
include Opennms::Rbac

unified_mode true
property :foreign_source_name, String, identity: true, required: true
property :sync_import, [TrueClass, FalseClass], default: false, desired_state: false
property :sync_wait_periods, Integer, default: 30, desired_state: false
property :sync_wait_secs, Integer, default: 10, desired_state: false
property :categories, Array, callbacks: { 'should be an array with string values' => ->(p) { !p.any? { |a| !a.is_a?(String) } } }
property :meta_data, kind_of:  Array, default: [], callbacks: {
  'should be an array of hashes with keys `context`, `key`, and `value` (strings)' => lambda { |p|
    p.is_a?(Array) && !p.any? { |a| !a.is_a?(Hash) || !a.key?('context') || !a['context'].is_a?(String) || !a.key?('key') || !a['key'].is_a?(String) || !a.key?('value') || !a['value'].is_a?(String) }
  },
}

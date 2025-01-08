include Opennms::Cookbook::Provision::ModelImportHttpRequest
include Opennms::XmlHelper
include Opennms::Rbac

unified_mode true
property :categories, Array
property :assets, Hash, callbacks: { 'should be a hash with key/value pairs that are both strings' => lambda { |p| !p.any? { |k, v| !k.is_a?(String) || !v.is_a?(String) } }, }
property :meta_data, kind_of:  [Array, Hash], default: [], callbacks: {
  'should be an array of hashes with keys `context`, `key`, and `value` (strings) or a hash where each key is a string representing `name` and which has a hash value with keys `type` and `context` (strings)' => lambda {
    |p| (p.is_a?(Hash) && !p.any? { |h, v| !h.is_a?(String) || !v.is_a?(Hash) || !v.key?('key') || !v['key'].is_a?(String) || !v.key?('value') || !v['value'].is_a?(String) }) || (p.is_a?(Array) && !p.any? { |a| !a.is_a?(Hash) || !a.key?('context') || !a['context'].is_a?(String) || !a.key?('key') || !a['key'].is_a?(String) || !a.key?('value') || !a['value'].is_a?(String) })
  },
}

action_class do
  include Opennms::XmlHelper
end

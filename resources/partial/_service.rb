include Opennms::XmlHelper
unified_mode true

property :service_name, String, name_property: true
property :package_name, String, identity: true, default: 'example1', required: true
property :class_name, String, required: true
# during non-update create, defaults to 300000
property :interval, Integer
# during non-update create, defaults to false
property :user_defined, [true, false]
# during non-update create, defaults to 'on'
property :status, String, equal_to: %w(on off)
property :timeout, [String, Integer]
property :port, [String, Integer]
property :parameters, Hash, callbacks: {
  'should be a hash with key/value pairs that are both strings' => lambda { |p|
    !p.any? { |k, v| !k.is_a?(String) || !v.is_a?(String) }
  },
}
property :class_parameters, Hash, callbacks: {
  'should be a hash with key/value pairs that are both strings' => lambda { |p|
    !p.any? { |k, v| !k.is_a?(String) || !v.is_a?(String) }
  },
}

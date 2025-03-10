unified_mode true
use 'partial/_base_service'

property :class_name, String, required: true
property :class_parameters, Hash, callbacks: {
  'should be a hash with key/value pairs that are both strings' => lambda { |p|
    !p.any? { |k, v| !k.is_a?(String) || !v.is_a?(String) }
  },
}

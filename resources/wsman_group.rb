property :group_name, String, name_attribute: true
property :file_name, String, required: true, identity: true
property :resource_type, String, required: true
property :resource_uri, String, required: true
property :dialect, String
property :filter, String
property :attribs, Array, required: true, callbacks: {
  'should be an array of hashes with the following required string keys with string values: `name`, `alias`, `type` (matches `([Cc](ounter|OUNTER)|[Gg](auge|AUGE)|[Ss](tring|TRING))`) and the following optional string keys with string values: `index-of`, `filter`' => lambda { |p|
    !p.any{ |h| !h.is_a?(Hash) || !h.key?('name') || !h['name'].is_a?(String) || !h.key?('alias') || !h['alias'].is_a?(String) || !h.key?('type') || !h['type'].is_a?(String) || !h['type'].match(/([Cc](ounter|OUNTER)|[Gg](auge|AUGE)|[Ss](tring|TRING))/) || (h.key?('index-of') && !h['index-of'].is_a?(String)) || (h.key?('filter') && !h['filter'].is_a?(String)) }
  }
} 
property :position, String, equal_to: %w(top bottom), default: 'bottom', deprecated: 'there is no utility in defining group order; therefore this property is now ignored and will be removed in the next major release'

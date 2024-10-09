unified_mode true

# name is used when this is nil
property :uei, String, identity: true
# relative path to file from $ONMS_HOME/etc, typically starts with `events/`
property :file, String, identity: true
# Array of hashes that contain key mename or vbnumber with a string value and mevalue or vbvalue with an array of string values. 'mename' indicates 'maskelement' while 'vbnumber' indicates 'varbind'. All vbnumber/vbvalue hashes must follow the mename/mevalue hashes.
# ex: [
#      {'mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.9.10.14']},
#      {'mename' => 'generic', 'mevalue' => ['6']},
#      {'mename' => 'specific', 'mevalue' => ['1']},
#      {'vbnumber' => '6', 'vbvalue' => ['1','2']}
#     ]
# As a special case, use the string '*' to indicate operating on the first event found with any mask
# and use the string '!' to indicate no mask
property :mask, [Array, String], default: '*', identity: true, callbacks: {
  'should either be an array of hashes where each hash has either keys `mename` and `mevalue` or `vbnumber` and `vbvalue`, or the string \'*\'.' => lambda {
    |p| (p.is_a?(String) && ['*', '!'].include?(p)) ||
    !p.any? { |h| !h.is_a?(Hash) || (h.key?('mename') && !h.key?('mevalue')) || (h.key?('vbnumber') && !h.key?('vbvalue')) || (!h.key?('mename') && !h.key?('vbnumber')) }
  }
}
property :priority, Integer, callbacks: {
  'should be a non-negative integer' => lambda {
    |p| p >= 0
  }
}
# this is required when creating a new event, but not when updating existing
property :event_label, String
# this is required when creating a new event, but not when updating existing
property :descr, String
# this is required when creating a new event, but not when updating existing
property :logmsg, String
# this is required when creating a new event, but not when updating existing. 'logndisplay' when in doubt.
property :logmsg_dest, String, equal_to: %w(logndisplay displayonly logonly suppress donotpersist discardtraps)
property :logmsg_notify, [true, false]
# an example using at least one of everything is:
# [
#   { 
#     'name' => 'nodeGroup',
#     'resource_type' => 'nodeSnmp',
#     'instance' => 'instanceParmName',
#     'collections' => [ { 'name' => 'TIME', 'type' => 'counter', 'param_values' => { 'primary` => 1, 'secondary' => 2 } }] }
#     'rrd' => { 
#                'rra' => [ 'RRA:AVERAGE:0.5:1:8928' ],
#                'step' => 60, 'heartbeat' => 120
#              }
#   }
# ]
property :collection_group, Array, callbacks: {
  'should be an array of hashes that contain key `rrd` with hash value consisting of key `rra` that is an array of strings that match pattern `RRA:(AVERAGE|MIN|MAX|LAST):.*`, `step` that is an integer; `name` with a string value; and `collections` which is an array of at least one hash containing key `name` with a string value' => lambda {
    |p| p.is_a?(Array) && !p.any? { |h| !h.key?('name') || !h.key?('rrd') || !h['rrd'].is_a?(Hash) || !h['rrd'].any? { |h2| !h2.key?('rra') || !h2['rra'].is_a?(Array) || !h2['rra'].any? { |a| !a.is_a?(String) || !a.match(/RRA:(AVERAGE|MIN|MAX|LAST):.*/) } || !h2.key?('step') } || !h['step'].is_a?(Integer) || !h.key?('collections') || !h['collections'].is_a?(Array) || !h['collections'].length > 0 || !h['collections'].any? { |ca| !ca.is_a?(Hash) || !ca.key?('name') } }
  }
}
# this is required when creating a new event, but not when updating existing. Use 'Indeterminate' if unknown.
property :severity, String
property :operinstruct, String
# Array of Hashes
# ex: [
#       {'action' => String, 'state' => 'on|off'},
#       ...
#     ]
property :autoaction, Array, callbacks: {
  'should be an array of hashes each of which contain a key named `action` and optionally a key named `state` with value of either `on` or `off`' => lambda {
    |p| p.is_a?(Array) && !p.any? { |h| !h.is_a?(Hash) || !h.key?('action') || !(h.key?('state') && !['on', 'off'].include?(p['state'])) }
  }
}
# Array of Hashes
# ex: [
#       { 'parmid' => String, 'decode' => [{'varbindvalue' => String, 'varbinddecodedstring' => String}, ...]},
#       ...
#     ]
property :varbindsdecode, Array, callbacks: {
  'should be an array of hashes each with a `parmid` key and a `decode` key with an array value of at least one hash that contains keys `varbindvalue` and `varbinddecodedstring`' => lambda {
    |p| p.is_a?(Array) && !p.any? { |h| !h.is_a(Hash) || !h.key?('parmid') || !h.key?('decode') || !h['decode'].is_a?(Array) || !h['decode'].length > 0  || !h['decode'].any? { |dh| !dh.is_a?(Hash) || !dh.key?('varbindvalue') || !dh.key?('varbinddecodedstring') } }
  }
}
# Array of Hashes
# ex: [
#       { 'name' => 'paramName', 'value' => 'someString', 'expand' => true },
#       ...
#     ]
# Support for parameters was added in 17 and enhanced with the 'expand' attribute in 18.
# They are ignored when using 16 and the expand attribute is ignored when using 17.
property :parameters, Array, callbacks: {
  'should be an array of hashes each with a `name` key and a `value` key and optionally an `expand` key with a boolean value' => lambda {
    |p| p.is_a?(Array) && !p.any? { |h| !h.is_a?(Hash) || !h.key?('name') || !h.key?('value') || !(h.key?('expand') && ![true, false, "true", "false"].include?(h['expand'])) }
  }
}
# Array of Hashes
# ex: [
#      {'action' => String, 'state' => 'on|off', 'menutext' => String},
#      ...
#    ]
property :operaction, Array, callbacks: {
  'should be an array of hashes each containing key `action`, key `menutext` and optionally key `state` with value of either `on` or `off`' => lambda {
    |p| p.is_a?(Array) && !p.any? { |h| !h.is_a?(Hash) || !h.key?('action') || !h.key?('menutext') || !(h.key?('state') && !['on', 'off'].include?(h['state'])) }
  }
}
# Hash with key `info` (string) and optional key `state` of either `on` or `off`
property :autoacknowledge, Hash, callbacks: {
  'should be a hash with key `info` key and optionally `state` key with value `on` or `off`' => lambda {
    |p| p.is_a?(Hash) && p.key?('info') && !(p.key?('state') && !['on', 'off'].include?(p['state']))
  }
}

property :loggroup, String
# A command to run (similar to autoaction), apparently to automatically create a trouble ticket when the event occurs
# ex:
#       { 'info' => String, 'state' => 'on|off' }
property :tticket, Hash, callbacks: {
  'should be a hash with key `info` key and optionally `state` key with value `on` or `off`' => lambda {
    |p| p.is_a?(Hash) && p.key?('info') && !(p.key?('state') && !['on', 'off'].include?(p['state']))
  }
}
# Array of Hash
# ex: [
#       { 'info' => String, 'state' => 'on|off', 'mechanism' => 'snmpudp|snmptcp|xmltcp|xmludp'},
#       ...
#     ]
property :forward, Array, callbacks: {
  'should be an array of hashes each of which contains keys `info` (string) and may contain keys `state` and `mechanism`' => lambda {
    |p| p.is_a?(Array) && !p.any?{ |h| !h.is_a?(Hash) || !h.key?('info') }
  }
}
# Array of Hash
# ex: [
#       {'name' => String, 'language' => String},
#       ...
#     ]
property :script, Array, callbacks: {
  'should be an array of hashes that each contain a `name` and `language` key' => lambda {
    |p| p.is_a?(Array) && !p.any? { |h| !h.is_a?(Hash) || !h.key?('name') || !h.key?('language') }
  }
}
property :mouseovertext, String
# See schema for required key/values.
# set to false to remove existing alarm-data
# ex: 'update_fields' => [{'field_name' => String, 'update_on_reduction' => true*|false}, ...], 'managed_object_type' => String, 'reduction_key' => String, 'alarm_type' => Fixnum, 'clear_key' => String, 'auto_clean' => true|false*, 'x733_alarm_type' => 'CommunicationsAlarm|ProcessingErrorAlarm|EnvironmentalAlarm|QualityOfServiceAlarm|EquipmentAlarm|IntegrityViolation|SecurityViolation|TimeDomainViolation|OperationalViolation|PhysicalViolation', 'x733_probable_cause' => Fixnum
property :alarm_data, [Hash, false], callbacks: {
  'should be a hash that contains keys `reduction_key` (string), `alarm_type` (integer). May contain keys `update_fields` (array of hashes that include mandatory key `field_name` (string) and optional keys `update_on_reduction` (boolean), `value_expression` (string)), `clear_key` (string), `auto_clean` (boolean), `x733_alarm_type` (string), `x733_probable_cause` (int)' => lambda {
    |p| [false].include?(p) || (p.is_a?(Hash) && !p.any? { |h| !h.is_a?(Hash) || !h.key?('reduction_key') || !h.key?('alarm_type') || !h['alarm_type'].is_a?(Integer) || !h['alarm_type'] > 0 })
  }
}
# used to change parm values of an event instance when the named parm's value matches the regular expression
property :filters, Array, callbacks: {
  'should be an array of hashes eachof which contains keys `eventparm` (string), `pattern` (string), `replacement` (string)' => lambda {
    |p| p.is_a?(Array) && !p.any?{ |h| !h.is_a?(Hash) || !h.key?('eventparm') || !h.key?('pattern') || !h.key?('replacement') }
  }
}
# control where in a file the event is added. Does not guarantee that the event will remain the first or last element in the file - once it exists in the file this attribute is ignored for purposes of whether or not the resource needs to be updated.
property :position, String, equal_to: %{top bottom}, default: 'bottom'
# if a new eventconf file is created as a result of this resource executing, this property controls the relative position that the reference to the new file is added to the main eventconf file
property :eventconf_position, String, equal_to: %w(override top bottom), default: 'bottom'

action_class do
  include Opennms::Cookbook::ConfigHelpers::Event::EventConfTemplate
  include Opennms::Cookbook::ConfigHelpers::Event::EventTemplate
end

load_current_value do |new_resource|
  # first we see if we exist
  current_value_does_not_exist! unless ::File.exist?("#{node['opennms']['conf']['home']}/etc/#{new_resource.file}")
  eventfile = Opennms::Cookbook::ConfigHelpers::Event::EventDefinitionFile.read("#{node['opennms']['conf']['home']}/etc/#{file}")
  event = eventfile.entry(new_resource.uei || new_resource.name, new_resource.mask)
  eventconf = Opennms::Cookbook::ConfigHelpers::Event::EventConf.read(node, "#{node['opennms']['conf']['home']}/etc/eventconf.xml")
  current_value_does_not_exist! if event.nil?
  current_value_does_not_exist! if eventconf.event_files[new_resource.file[7..-1]].nil?
  # Okay, we do exist. let's load up the current values
  %i(priority event_label descr logmsg logmsg_dest logmsg_notify collection_group severity operinstruct autoaction varbindsdecode parameters operaction autoacknowledge loggroup tticket forward script mouseovertext alarm_data filters).each do |p|
    send(p, event.send(p))
  end
  # skipping `position` as we don't ever change position of an event in a file once it exists
  eventconf_position eventconf.event_files[new_resource.file[7..-1]][:position]
end

action :create do
  converge_if_changed do
    eventconf_resource_init
    eventconf_resource.variables[:eventconf].event_files[new_resource.file] = { position: new_resource.eventconf_position }
    eventfile_resource_init
    entry = eventfile_resource.variables[:events].entry(new_resource.uei || new_resource.name, new_resource.mask)
    if entry.nil?
      resource_properties = %i(uei mask priority event_label descr logmsg logmsg_dest logmsg_notify collection_group severity operinstruct autoaction varbindsdecode parameters operaction autoacknowledge loggroup tticket forward script mouseovertext alarm_data filters).map{ |p| [p, new_resource.send(p)] }.to_h.compact
      entry = Opennms::Cookbook::ConfigHelpers::Event::EventDefinition.create(**resource_properties)
      eventfile_resource.variables[:events].add(entry, new_resource.position)
    else
      run_action(:update)
    end
  end
end

action :update do
  converge_if_changed(:priority, :event_label, :descr, :logmsg, :logmsg_dest, :logmsg_notify, :collection_group, :severity, :operinstruct, :autoaction, :varbindsdecode, :parameters, :operaction, :autoacknowledge, :loggroup, :tticket, :forward, :script, :mouseovertext, :alarm_data, :filters) do
    eventfile_resource_init
    entry = eventfile_resource.variables[:events].entry(new_resource.uei || new_resource.name, new_resource.mask)
    raise Chef::Exceptions::CurrentValueDoesNotExist, "Cannot update event definition for '#{new_resource.name}' as it does not exist" if entry.nil?
    entry.update(priority: new_resource.priority,
                 event_label: new_resource.event_label,
                 descr: new_resource.descr,
                 logmsg: new_resource.logmsg,
                 logmsg_dest: new_resource.logmsg_dest,
                 logmsg_notify: new_resource.logmsg_notify,
                 collection_group: new_resource.collection_group,
                 severity: new_resource.severity,
                 operinstruct: new_resource.operinstruct,
                 autoaction: new_resource.autoaction,
                 varbindsdecode: new_resource.varbindsdecode,
                 parameters: new_resource.parameters,
                 operaction: new_resource.operaction,
                 autoacknowledge: new_resource.autoacknowledge,
                 loggroup: new_resource.loggroup,
                 tticket: new_resource.tticket,
                 forward: new_resource.forward,
                 script: new_resource.script,
                 mouseovertext: new_resource.mouseovertext,
                 alarm_data: new_resource.alarm_data,
                 filters: new_resource.filters
                )
  end
end

action :delete do
  eventconf_resource_init
  eventconf_resource.variables[:eventconf].event_files.delete(new_resource.file[7..-1])
  file "#{node['opennms']['conf']['home']}/etc/#{new_resource.file}" do
    action :delete
  end
end

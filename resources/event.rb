require 'rexml/document'

# Add an event to an eventconf file. Will create the event file if it does not exist. Fails if file exists but 
# is not an eventconf file.  If new file, will add it to main eventconf.xml file.

actions :create
default_action :create

attribute :uei, :kind_of => String, :name_attribute => true
# should include full relative path to file from $ONMS_HOME/etc
attribute :file, :kind_of => String, :default => 'eventconf.xml', :required => true
# Array of hashes that contain keys mename with a string value and mevalue with an array of string values. 
# ex: [
#      {'mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.9.10.14']}, 
#      {'mename' => 'generic', 'mevalue' => ['6']}, 
#      {'mename' => 'specific', 'mevalue' => ['1']}
#     ]
attribute :mask, :kind_of => Hash
attribute :event_label, :kind_of => String, :required => true
# Never seen this in the wild but it's in the schema.
# ex: 'id' => 'string', 'idtext' => 'string', 'version' => 'v1|v2c|v3', 'specific' => Fixnum, 'generic' => Fixnum, 'community' => 'string'
# Also, not yet implemented in the provider
attribute :snmp, :kind_of => Hash
attribute :descr, :kind_of => String, :required => true
attribute :logmsg, :kind_of => String, :required => true
attribute :logmsg_dest, :kind_of => String, :equal_to => ['logndisplay','displayonly','logonly','suppress','donotpersist','discardtraps'], :default => 'logndisplay', :required => true
attribute :logmsg_notify, :kind_of => [TrueClass, FalseClass], :default => true
attribute :severity, :kind_of => String, :default => 'Indeterminate', :required => true
# Never seen this used, but is present in the schema. 
# ex: 'cuei' => [Strings], 'cmin' => Fixnum, 'cmax' => Fixnum, 'ctime' => String, 'state' => 'on|off', 'path' => 'suppressDuplicates|cancellingEvent|suppressAndCancel|pathOutage'
# Also, not yet implemented in the provider
attribute :correlation, :kind_of => Hash
attribute :operinstruct, :kind_of => String
# Array of Hashes
# ex: [
#       {'action' => String, 'state' => 'on|off'}, 
#       ...
#     ]
attribute :autoaction, :kind_of => Array 
# Array of Hashes
# ex: [
#       { 'parmid' => String, 'decode' => [{'varbindvalue' => String, 'varbinddecodedstring' => String}, ...]}, 
#       ...
#     ]
attribute :varbindsdecode, :kind_of => Array
#Array of Hashes
#ex: [
#      {'action' => String, 'state' => 'on|off', 'menutext' => String},
#      ...
#    ]
# Also, not yet implemented in the provider
attribute :operaction, :kind_of => Array
# ex:  'info' => String, 'state' => 'on|off'
# Also, not yet implemented in the provider
attribute :autoacknowledge, :kind_of => Hash
# Array of Strings
# Not yet implemented in the provider
attribute :loggroup, :kind_of => Array
# ex: 'info' => String, 'state' => 'on|off'
attribute :tticket, :kind_of => Hash
# Array of Hash
# ex: [
#       { 'info' => String, 'state' => 'on|off', 'mechanism' => 'snmpudp|snmptcp|xmltcp|xmludp'}, 
#       ...
#     ]
attribute :forward, :kind_of => Array
# Array of Hash
# ex: [
#       {'name' => String, 'language' => String},
#       ...
#     ]
attribute :script, :kind_of => Array
attribute :mouseovertext, :kind_of => String
# See schema for required key/values. 
# ex: 'update_fields' => [{'field_name' => String, 'update_on_reduction' => true*|false}, ...], 'reduction_key' => String, 'alarm_type' => Fixnum, 'clear_key' => String, 'auto_clean' => true|false*, 'x733_alarm_type' => 'CommunicationsAlarm|ProcessingErrorAlarm|EnvironmentalAlarm|QualityOfServiceAlarm|EquipmentAlarm|IntegrityViolation|SecurityViolation|TimeDomainViolation|OperationalViolation|PhysicalViolation', 'x733_probable_cause' => Fixnum
attribute :alarm_data, :kind_of => Hash

attr_accessor :exists, :file_exists, :is_event_file

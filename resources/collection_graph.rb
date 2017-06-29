# frozen_string_literal: true
# Adds/updates/deletes a graph in either the specified currently existing or
# new graph file in $ONMS_HOME/etc/snmp-graph.properties.d/
# or the default collection graph file, $ONMS_HOME/etc/snmp-graph.properties

actions :create, :create_if_missing, :delete
default_action :create

attribute :short_name, kind_of: String, name_attribute: true
attribute :long_name, kind_of: String, required: true
attribute :columns, kind_of: Array, required: true
attribute :type, kind_of: String, default: 'nodeSnmp', required: true
attribute :command, kind_of: String, required: true
attribute :file, kind_of: String # refers to the name of the file to add the graph def to

attr_accessor :exists, :type_exists, :file_exists

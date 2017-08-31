# frozen_string_literal: true
# shorthand to deploy a graph file to $ONMS_HOME/etc/snmp-graph.properties.d/
actions :create, :create_if_missing, :delete, :touch
default_action :create

attribute :file, kind_of: String, name_attribute: true

attr_accessor :exists

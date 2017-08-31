# frozen_string_literal: true
# Adds/updates/deletes a graph in $ONMS_HOME/etc/response-graph.properties
actions :create, :create_if_missing, :delete
default_action :create

attribute :short_name, kind_of: String, name_attribute: true
attribute :long_name, kind_of: String, required: false # defaults to uppercase short_name if not present
attribute :columns, kind_of: Array, required: false # defaults to short_name if not present
attribute :type, kind_of: Array, default: %w(responseTime distributedStatus), required: true
attribute :command, kind_of: String, required: false # a generic graph will be generated with min, max avg if not present

attr_accessor :exists, :type_exists

# frozen_string_literal: true
require 'rexml/document'

# Defines data to collect in a WS-Man collection in
# $ONMS_HOME/etc/wsman-datacollection-config.xml.

actions :create, :delete
default_action :create

attribute :name, name_attribute: true, kind_of: String, required: true
attribute :group_name, kind_of: String, required: false
attribute :file_name, kind_of: String, required: true
attribute :resource_type, kind_of: String, required: true
attribute :resource_uri, kind_of: String, required: true
attribute :dialect, kind_of: String, required: false
attribute :filter, kind_of: String, required: false
attribute :attribs, kind_of: Array, default: []
attribute :position, kind_of: String, equal_to: %w(top bottom), default: 'bottom'

attr_accessor :exists, :file_path

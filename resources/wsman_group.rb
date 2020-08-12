# frozen_string_literal: true
require 'rexml/document'

# Defines data to collect in a WS-Man collection in
# $ONMS_HOME/etc/wsman-datacollection-config.xml. The collection_name must
# reference an existing collection defined by the wsman_collection LWRP.

actions :create
default_action :create

attribute :file, kind_of: String, default: 'wsman-datacollection-config.xml', required: true
attribute :group_name, name_attribute: true, kind_of: String, required: true
attribute :resource_type, kind_of: String, default: 'node', required: true
attribute :resource_uri, kind_of: String, default: 'http://schemas.dell.com/wbem/wscim/1/cim-schema/2/root/dcim/DCIM_ComputerSystem', required: true
attribute :dialect, kind_of: String, required: false
attribute :filter, kind_of: String, required: false
attribute :attribs, kind_of: Hash, default: {}
attribute :position, kind_of: String, equal_to: %w(top bottom), default: 'bottom'

attr_accessor :exists, :file_exists, :new_file, :is_group_file, :changed, :file_path
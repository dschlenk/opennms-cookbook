# frozen_string_literal: true
require 'rexml/document'

# Defines data to collect in a WS-Man collection in
# $ONMS_HOME/etc/wsman-datacollection-config.xml. The collection_name must
# reference an existing collection defined by the wsman_collection LWRP.

actions :create
default_action :create

attribute :name, name_attribute: true, kind_of: String, required: true
attribute :collection_name, name_attribute: true, kind_of: String, required: true
attribute :if_type, kind_of: String, required: true
attribute :recheck_interval, kind_of: Integer, default: 3_600_000
attribute :resource_type, kind_of: String, default: 'node', required: true
attribute :resource_uri, kind_of: String, default: 'http://schemas.dell.com/wbem/wscim/1/cim-schema/2/root/dcim/DCIM_ComputerSystem', required: true
attribute :attribs, kind_of: Hash, default: {}

attr_accessor :exists, :collection_exists, :resource_type_exists

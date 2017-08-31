# frozen_string_literal: true
require 'rexml/document'

# Defines data to collect in a WMI collection in
# $ONMS_HOME/etc/wmi-datacollection-config.xml. The collection_name must
# reference an existing collection defined by the wmi_collection LWRP.

actions :create
default_action :create

attribute :name, name_attribute: true, kind_of: String, required: true
attribute :collection_name, name_attribute: true, kind_of: String, required: true
attribute :if_type, kind_of: String, required: true
attribute :recheck_interval, kind_of: Integer, default: 3_600_000
attribute :resource_type, kind_of: String, default: 'node', required: true
attribute :keyvalue, kind_of: String, required: true
attribute :wmi_class, kind_of: String, required: true
attribute :wmi_namespace, kind_of: String
# hash: {'name' => { 'alias' => 'LessThan20Char', 'wmi_object' => 'TheThing', 'type' => 'gauge|counter|etc'}, ... }
attribute :attribs, kind_of: Hash, default: {}

attr_accessor :exists, :collection_exists, :resource_type_exists

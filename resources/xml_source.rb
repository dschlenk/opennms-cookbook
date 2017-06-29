# frozen_string_literal: true
require 'rexml/document'

# Defines data to collect in an XML collection in
# $ONMS_HOME/etc/xml-datacollection-config.xml. The collection_name must
# reference an existing collection defined by the xml_collection LWRP.
# Similar to SNMP, the xml-datacollection-config.xml file can be modularized.
# This LWRP supports either method using either the import_groups (array
# of cookbook_file names) or xml_groups (hash object representing XML
#  xml-group elements) attributes.
#
# Equivalence/identity determined by all attributes except request_content

actions :create, :delete
default_action :create

attribute :name, name_attribute: true, kind_of: String, required: true
# name used as url when url not specified
attribute :url, name_attribute: true, kind_of: String
attribute :collection_name, kind_of: String, required: true
# GET or POST etc
attribute :request_method, kind_of: String
# key/value pairs
attribute :request_params, kind_of: Hash
# key/value pairs
attribute :request_headers, kind_of: Hash
# will be wrapped in a CDATA element
attribute :request_content, kind_of: String
# an array of String filenames (that contain xml-groups/xml-group[0..*]/xml-object[0..*])
attribute :import_groups, kind_of: Array, default: []
# or xml_groups, which is an array of hashes like
# { 'name' => { 'resource_type' => 'anResourceType', 'resource_xpath' => '/the/resource/xpath',
#   'key_xpath' => '@key', {'object_name' => {'type'=> 'string|gauge|etc', 'xpath' => 'more[@xpath='objectname']'}, ... } }, ... }
# attribute :xml_groups, :kind_of => Hash, :default => {}
attr_accessor :exists, :collection_exists

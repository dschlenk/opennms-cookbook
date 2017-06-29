# frozen_string_literal: true
require 'rexml/document'

# Defines data to be collected in a JMX collection in
# $ONMS_HOME/etc/jmx-datacollection-config.xml. The collection_name must
# reference an existing collection defined with the jmx_collection LWRP.

actions :create
default_action :create

attribute :name, name_attribute: true, kind_of: String, required: true
attribute :collection_name, kind_of: String, required: true
attribute :objectname, kind_of: String, required: true
# hash of form: { 'name' => { 'alias' => 'theAlias', 'type' => 'gauge|string|etc'[,'data_source_name' => 'theDataSourceName] }, ... }
attribute :attribs, kind_of: Hash, default: {}

attr_accessor :exists, :collection_exists

# frozen_string_literal: true
require 'rexml/document'

# Defines data to be collected in a JDBC collection in
# $ONMS_HOME/etc/jdbc-datacollection-config.xml. The collection_name must
# reference an existing collection defined with the jdbc_collection LWRP.

actions :create
default_action :create

attribute :name, name_attribute: true, kind_of: String, required: true
attribute :collection_name, kind_of: String, required: true
attribute :if_type, kind_of: String, default: 'ignore', required: true
attribute :recheck_interval, kind_of: Integer, default: 3_600_000, required: true
attribute :resource_type, kind_of: String, default: 'nodeSnmp', required: true
attribute :instance_column, kind_of: String
attribute :query_string, kind_of: String, required: true
# hash of form: { 'name' => { 'alias' => 'theAlias', 'type' => 'gauge|string|etc'[,'data_source_name' => 'theDataSourceName] }, ... }
attribute :columns, kind_of: Hash, default: {}

attr_accessor :exists, :collection_exists, :resource_type_exists

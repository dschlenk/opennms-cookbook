# frozen_string_literal: true
require 'rexml/document'

# Defines a collection in $ONMS_HOME/etc/jdbc-datacollection-config.xml.
# Will be used by any packages in $ONMS_HOME/etc/collectd-configuration.xml
# that have a JDBC service with this collection name as the collection
# parameter value. You can use the jdbc_collection_service LWRP to create
# that service, the collection_package LWRP to define the package and the
# jdbc_query LWRP to define the queries in this jdbc_collection.

actions :create
default_action :create

attribute :collection, name_attribute: true, kind_of: String, required: true
attribute :rrd_step, kind_of: Integer, required: true
attribute :rras, kind_of: Array, required: true

attr_accessor :exists

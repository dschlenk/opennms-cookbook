require 'rexml/document'
# Defines a collection in $ONMS_HOME/etc/datacollection-config.xml. 
# Will be used by any packages in $ONMS_HOME/etc/collectd-configuration.xml
# that have an SNMP service with this collection name as the collection
# parameter value. You can use the snmp_collection_service LWRP to create 
# that service, the collection_package LWRP to define the package and the 
# snmp_collection_group LWRP to define the data collected in this collection.

actions :create
default_action :create

attribute :collection, :name_attribute => true, :kind_of => String, :required => true
attribute :service_name, :kind_of => String, :required => true, :default => 'SNMP'
attribute :max_vars_per_pdu, :kind_of =>  Fixnum, :default => 50
attribute :snmp_stor_flag, :kind_of => String, :equal_to => ["all", "select","primary"], :default => "select", :required => true
attribute :rrd_step, :kind_of => Fixnum, :default => 300, :required => true
attribute :rras, :kind_of => Array, :required => true

attr_accessor :exists

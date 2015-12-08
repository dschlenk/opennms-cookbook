require 'rexml/document'

# Use this LWRP to include a XML collection in the referenced collectd 
# package_name. This LWRP simply adds the service to the package in 
# $ONMS_HOME/etc/collectd-configuration.xml. You'll need to define the 
# collection elements using the xml_collection and the data to collect 
# in the xml_source LWRPs respectively. The package is created with the 
# collection_package LWRP.

actions :create
default_action :create

attribute :name, :name_attribute => true, :kind_of => String
attribute :service_name, :kind_of => String, :default => 'XML', :required => true
attribute :package_name, :kind_of => String, :default => 'example1', :required => true
attribute :collection, :kind_of => String, :default => 'default', :required => true
attribute :interval, :kind_of => Fixnum, :default => 300000, :required => true
attribute :user_defined, :kind_of => [FalseClass, TrueClass], :default => false
attribute :status, :kind_of => String, :equal_to => ['on','off'], :default => 'on', :required => true
attribute :timeout, :kind_of => Fixnum, :default => 3000
attribute :retry_count, :kind_of => Fixnum, :default => 1
attribute :port, :kind_of => Fixnum
attribute :thresholding_enabled, :kind_of => [FalseClass, TrueClass], :default => false

attr_accessor :exists

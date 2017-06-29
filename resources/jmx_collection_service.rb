# frozen_string_literal: true
require 'rexml/document'

# Use this LWRP to include a JMX collection in the referenced collectd
# package_name. This LWRP simply adds the service to the package in
# $ONMS_HOME/etc/collectd-configuration.xml. You'll need to define the
# collection elements using the jmx_collection and jdbc_mbean LWRPs.
# The package is created with the collection_package LWRP.

actions :create
default_action :create

attribute :service_name, name_attribute: true, kind_of: String
attribute :package_name, kind_of: String, default: 'example1'
attribute :collection, kind_of: String, default: 'default'
attribute :interval, kind_of: Integer, default: 300000
attribute :user_defined, kind_of: [FalseClass, TrueClass], default: false
attribute :status, kind_of: String, equal_to: %w(on off), default: 'on'
attribute :timeout, kind_of: Integer, default: 3000
attribute :retry_count, kind_of: Integer, default: 1
attribute :thresholding_enabled, kind_of: [FalseClass, TrueClass], default: false
attribute :port, kind_of: Integer, default: 1099
attribute :protocol, kind_of: String, default: 'rmi'
attribute :url_path, kind_of: String, default: '/jmxrmi'
attribute :rrd_base_name, kind_of: String, default: 'java'
attribute :ds_name, kind_of: String, required: true
attribute :friendly_name, kind_of: String, required: true

attr_accessor :exists, :collection_exists

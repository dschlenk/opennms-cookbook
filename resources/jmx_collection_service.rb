# frozen_string_literal: true
require 'rexml/document'

# Use this LWRP to include a JMX collection in the referenced collectd
# package_name. This LWRP simply adds the service to the package in
# $ONMS_HOME/etc/collectd-configuration.xml. You'll need to define the
# collection elements using the jmx_collection and jdbc_mbean LWRPs.
# The package is created with the collection_package LWRP.

# The parameters port, protocol, url_path, rmi_server_port and remote_jmx are
# deprecated and should be replaced with the url parameter. If url is not
# defined then the deprecated attributes are used instead.

# Note that configuration of a particular service can can be overwritten by
# an entry in $OPENNMS_HOME/etc/jmx-config.xml.

actions :create, :delete
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
attribute :factory, kind_of: String, equal_to: %w(STANDARD PASSWORD_CLEAR SASL)
attribute :username, kind_of: String
attribute :password, kind_of: String
attribute :port, kind_of: Integer, default: 1099
attribute :protocol, kind_of: String, default: 'rmi'
attribute :url_path, kind_of: String, default: '/jmxrmi'
attribute :url, kind_of: String
attribute :rmi_server_port, kind_of: Integer
attribute :remote_jmx, kind_of: [TrueClass, FalseClass]
attribute :rrd_base_name, kind_of: String, default: 'java'
attribute :ds_name, kind_of: String, required: true
attribute :friendly_name, kind_of: String, required: true

attr_accessor :exists, :collection_exists

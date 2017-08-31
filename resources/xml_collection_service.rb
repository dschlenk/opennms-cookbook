# frozen_string_literal: true
require 'rexml/document'

# Use this LWRP to include a XML collection in the referenced collectd
# package_name. This LWRP simply adds the service to the package in
# $ONMS_HOME/etc/collectd-configuration.xml. You'll need to define the
# collection elements using the xml_collection and the data to collect
# in the xml_source LWRPs respectively. The package is created with the
# collection_package LWRP.

actions :create, :create_if_missing, :delete
default_action :create

attribute :name, name_attribute: true, kind_of: String
attribute :service_name, kind_of: String, default: 'XML', required: true
attribute :package_name, kind_of: String, default: 'example1', required: true
attribute :collection, kind_of: String, default: 'default', required: true
# during non-update create, defaults to 300000
attribute :interval, kind_of: Integer
# during non-update create, defaults to false
attribute :user_defined, kind_of: [FalseClass, TrueClass]
# during non-update create, defaults to 'on'
attribute :status, kind_of: String, equal_to: %w(on off)
# during non-update create, defaults to 3000
attribute :timeout, kind_of: Integer
# during non-update create, defaults to 1
attribute :retry_count, kind_of: Integer
attribute :port, kind_of: Integer
# during non-update create, defaults to false
attribute :thresholding_enabled, kind_of: [FalseClass, TrueClass]

attr_accessor :exists, :changed

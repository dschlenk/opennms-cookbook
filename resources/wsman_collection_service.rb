# frozen_string_literal: true
require 'rexml/document'

# Use this LWRP to include a WS-Man collection in the referenced collectd
# package_name. This LWRP simply adds the service to the package in
# $ONMS_HOME/etc/collectd-configuration.xml. You'll need to define the
# collection elements using the wsman_collection and the data to collect
# using the wsman_group LWRPs. The package is created with the collection_package
# LWRP.

actions :create, :delete
default_action :create

# not used in config

attribute :service_name, kind_of: String, required: true
attribute :collection, kind_of: String, required: true
attribute :package_name, kind_of: String, required: true
attribute :interval, kind_of: Integer, required: true
attribute :user_defined, kind_of: [FalseClass, TrueClass], default: false
attribute :status, kind_of: String, equal_to: %w(on off), required: true
attribute :timeout, kind_of: Integer, default: 3000
attribute :retry_count, kind_of: Integer, default: 1
attribute :port, kind_of: Integer
attribute :thresholding_enabled, kind_of: [FalseClass, TrueClass], default: false

attr_accessor :exists, :changed

# frozen_string_literal: true
require 'rexml/document'
# Use this LWRP to include a collection in the referenced collectd
# package_name. This LWRP simply adds the service to the package in
# $ONMS_HOME/etc/collectd-configuration.xml. You'll need to define the
# collection elements using the appropriate LWRPs for the type of collection
# being performed. The package is created with the collection_package LWRP.
actions :create
default_action :create

attribute :service_name, name_attribute: true, kind_of: String, required: true
attribute :collection, kind_of: String, required: true, default: 'default'
attribute :package_name, kind_of: String, required: true
attribute :class_name, kind_of: String, required: true
attribute :interval, kind_of: Integer, default: 300_000, required: true
attribute :user_defined, kind_of: [FalseClass, TrueClass], default: false
attribute :status, kind_of: String, equal_to: %w(on off), default: 'on', required: true
attribute :timeout, kind_of: Integer, default: 3000
attribute :retry_count, kind_of: Integer, default: 1
attribute :port, kind_of: Integer, default: 161
attribute :params, kind_of: Hash
attribute :thresholding_enabled, kind_of: [FalseClass, TrueClass], default: false

attr_accessor :exists

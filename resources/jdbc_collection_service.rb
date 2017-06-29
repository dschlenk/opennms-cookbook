# frozen_string_literal: true
require 'rexml/document'

# Use this LWRP to include a JDBC collection in the referenced collectd
# package_name. This LWRP simply adds the service to the package in
# $ONMS_HOME/etc/collectd-configuration.xml. You'll need to define the
# collection elements using the jdbc_collection and jdbc_query LWRPs.
# The package is created with the collection_package LWRP.

actions :create, :create_if_missing, :delete
default_action :create

# Uniqueness/identity of this resource is determined by service_name,
# package_name, and collection.
# Update implied by create action.
# name doesn't actually get used for anything in the config but exists to avoid
# that dumb chef resource clone thing.
attribute :name, name_attribute: true, kind_of: String
attribute :service_name, kind_of: String, default: 'JDBC', required: true
attribute :package_name, kind_of: String, default: 'example1', required: true
attribute :collection, kind_of: String, default: 'default', required: true
# defaults to 300000 during create
attribute :interval, kind_of: Integer # , :default => 300000
attribute :user_defined, kind_of: [FalseClass, TrueClass] # , :default => false
# defaults to 'on' during create
attribute :status, kind_of: String, equal_to: %w(on off) # , :default => 'on'
# defaults to 3000 during create
attribute :timeout, kind_of: Integer # , :default => 3000
# defaults to 1 during create
attribute :retry_count, kind_of: Integer # , :default => 1
# defaults to false during create
attribute :thresholding_enabled, kind_of: [FalseClass, TrueClass] # , :default => false
# The rest of the attributes are generally required for create action, but not
# enforced at the resource level. They have no implicit defaults during create.
# This is done to allow updating without specifying the entire resource again.
attribute :driver, kind_of: String
attribute :driver_file, kind_of: String
attribute :user, kind_of: String
attribute :password, kind_of: String
attribute :port, kind_of: Integer
attribute :url, kind_of: String

attr_accessor :exists, :collection_exists, :changed

# frozen_string_literal: true
require 'rexml/document'

# this one supports updating. existance determined by service_name/package_name.
actions :create, :delete
default_action :create

attribute :service_name, kind_of: String
attribute :package_name, kind_of: String, required: true
attribute :interval, kind_of: Integer, required: true
attribute :user_defined, kind_of: [TrueClass, FalseClass], required: true
attribute :status, kind_of: String, equal_to: %w(on off), required: true
attribute :timeout, kind_of: Integer, default: 3000, required: false
attribute :port, kind_of: Integer
# key/value pairs for other service parameters or false if none
# NOTE: during initial create an empty hash is functionally identical to false
# but for updates an empty hash means leave whatever parameters are there alone
# whereas false means remove any existing parameters
attribute :parameters, kind_of: [Hash, FalseClass], default: {}
attribute :class_name, kind_of: String, required: true

attr_accessor :exists, :package_exists, :changed

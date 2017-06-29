# frozen_string_literal: true
require 'rexml/document'

# this one supports updating. existance determined by service_name/package_name.
actions :create
default_action :create

attribute :service_name, name_attribute: true, kind_of: String, required: true
attribute :package_name, kind_of: String, default: 'example1', required: true
attribute :interval, kind_of: Integer, default: 300_000, required: true
attribute :user_defined, kind_of: [TrueClass, FalseClass], default: false, required: true
attribute :status, kind_of: String, equal_to: %w(on off), default: 'on', required: true
attribute :timeout, kind_of: Integer, default: 3000, required: false
attribute :port, kind_of: Integer
# key/value pairs for other service parameters
attribute :params, kind_of: Hash, default: {}
attribute :class_name, kind_of: String, required: true

attr_accessor :exists, :package_exists, :changed

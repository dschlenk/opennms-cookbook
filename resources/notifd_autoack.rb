# frozen_string_literal: true
require 'rexml/document'
actions :create
default_action :create

attribute :uei, kind_of: String, name_attribute: true
attribute :acknowledge, kind_of: String, required: true
attribute :resolution_prefix, kind_of: String, default: 'RESOLVED: '
attribute :notify, kind_of: [TrueClass, FalseClass], default: true
# Array of strings. At least one required. Defaults to a single string - 'nodeid'
attribute :matches, kind_of: Array, default: ['nodeid'], required: true

attr_accessor :exists

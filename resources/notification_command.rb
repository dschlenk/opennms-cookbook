# frozen_string_literal: true
require 'rexml/document'
actions :create
default_action :create

attribute :name, kind_of: String, name_attribute: true
attribute :execute, kind_of: String, required: true
attribute :comment, kind_of: String
attribute :contact_type, kind_of: String
attribute :binary, kind_of: [TrueClass, FalseClass], default: true
# To maintain order, an array of hashes with up to three key/values pairs. Only 'streamed' is required.
# [{'streamed' => '(true|false)', 'substitution' => 'string', 'switch' => 'string'}, {...}]
attribute :arguments, kind_of: Array

attr_accessor :exists

# frozen_string_literal: true
require 'rexml/document'

actions :create, :delete
default_action :create

attribute :name, kind_of: String, required: true
# name is used when group_name not specified
attribute :group_name, kind_of: String
attribute :source_url, kind_of: String, required: true
attribute :collection_name, kind_of: String, required: true
attribute :resource_type, kind_of: String, default: 'node', required: true
attribute :resource_xpath, kind_of: String, required: true
attribute :key_xpath, kind_of: String
attribute :timestamp_xpath, kind_of: String
attribute :timestamp_format, kind_of: String
# like: 'object_name' => {'type' => 'string|gauge|etc', 'xpath' => 'the/xpath'}, 'another_object_name' -> { ... }, ...
attribute :objects, kind_of: Hash, default: {}
attr_accessor :exists, :collection_exists, :source_exists, :resource_type_exists

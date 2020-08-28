# frozen_string_literal: true
require 'rexml/document'

actions :add, :remove
default_action :add

attribute :name, name_attribute: true, kind_of: String, required: true
attribute :groups, kind_of: Array, required: true
attribute :file_name, kind_of: String, default: 'wsman-datacollection-config.xml', required: true
attribute :position, kind_of: String, equal_to: %w(top bottom), default: 'bottom'

attr_accessor :exists, :file_path, :group_exists

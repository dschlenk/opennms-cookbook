# frozen_string_literal: true
require 'rexml/document'

actions :create
default_action :create

attribute :name,        kind_of: String, name_attribute: true, required: true
attribute :range_begin, kind_of: String, required: true
attribute :range_end,   kind_of: String, required: true
attribute :range_type,  kind_of: String, default: 'include', equal_to: %w(include exclude), required: true
attribute :retry_count, kind_of: Integer
attribute :timeout,     kind_of: Integer
# OpenNMS 18+
attribute :location, kind_of: String
attribute :foreign_source, kind_of: String
attr_accessor :exists, :foreign_source_exists

# frozen_string_literal: true
require 'rexml/document'

actions :create
default_action :create

attribute :url, kind_of: String, name_attribute: true, required: true
attribute :file_name, kind_of: String
attribute :retry_count, kind_of: Integer
attribute :timeout, kind_of: Integer
# OpenNMS 18+
attribute :location, kind_of: String
attribute :foreign_source, kind_of: String
attr_accessor :exists, :foreign_source_exists

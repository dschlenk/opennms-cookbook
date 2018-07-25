# frozen_string_literal: true
require 'rexml/document'

actions :create, :delete
default_action :create

attribute :name, kind_of: String, name_attribute: true
attribute :outage_name, kind_of: String
# "id" => { "day" => "(monday|tuesday|wednesday|thursday|friday|saturday|sunday|[1-3][0-9]|[1-9])", "begins" => "dd-MMM-yyyy HH:mm:ss", "ends" => "HH:mm:ss" }
attribute :times, kind_of: Hash, required: true, default: {}
attribute :type, kind_of: String, equal_to: %w(specific daily weekly monthly), required: true
attribute :interfaces, kind_of: Array, default: [] # of IP addresses as strings
attribute :nodes, kind_of: Array, default: [] # of node IDs

attr_accessor :exists

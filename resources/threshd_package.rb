# frozen_string_literal: true
require 'rexml/document'

actions :create, :create_if_missing, :delete
default_action :create

attribute :name, kind_of: String, required: true, name_attribute: true
# identity is defined exclusively by package_name
attribute :package_name, kind_of: String
attribute :filter, kind_of: String, required: true
attribute :specifics, kind_of: Array
# arrays of hashes each containing begin and end keys
attribute :include_ranges, kind_of: Array
attribute :exclude_ranges, kind_of: Array
attribute :include_urls, kind_of: Array
# array of hashes of the form
# [{ 'name' => 'SNMP', 'interval' => Fixnum, 'status' => 'on|off', 'params' => {'key' => 'value', ... }}, ...]
attribute :services, kind_of: Array
# array of strings referencing an outage calendar name TODO validate exists
attribute :outage_calendars, kind_of: Array

attr_accessor :exists, :changed

# frozen_string_literal: true
require 'rexml/document'

actions :create
default_action :create

attribute :package_name, kind_of: String, required: true, name_attribute: true
attribute :filter, kind_of: String, default: "IPADDR != '0.0.0.0'", required: true
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

attr_accessor :exists

# frozen_string_literal: true
require 'rexml/document'
require 'rexml/cdata'

# Creates a package in $ONMS_HOME/etc/collectd-configuration.xml
# You don't define services here but rather using the appropriate
# service LWRP (snmp, wmi, nsclient, jmx,  http, xml, jdbc).

actions :create
default_action :create

attribute :package_name, kind_of: String, required: true, name_attribute: true
attribute :filter, kind_of: String, required: true
attribute :specifics, kind_of: Array, default: []
attribute :include_ranges, kind_of: Array, default: []
attribute :exclude_ranges, kind_of: Array, default: []
attribute :include_urls, kind_of: Array, default: []
attribute :store_by_if_alias, kind_of: [TrueClass, FalseClass], default: false
attribute :store_by_node_id, kind_of: [String, TrueClass, FalseClass], default: 'normal'
attribute :if_alias_domain, kind_of: String
attribute :stor_flag_override, kind_of: [TrueClass, FalseClass], default: false
attribute :if_alias_comment, kind_of: String
attr_accessor :exists

# frozen_string_literal: true
require 'rexml/document'

actions :create
default_action :create

attribute :label, kind_of: String, name_attribute: true
# containing CategoryGroup, default is the default OpenNMS ships with
attribute :category_group, kind_of: String, default: 'WebConsole'
attribute :comment, kind_of: String
attribute :normal, kind_of: Float, default: 99.99
attribute :warning, kind_of: Float, default: 97.0
attribute :rule, kind_of: String, default: "IPADDR != '0.0.0.0'"
# array of Strings of services in poller or collectd
attribute :services, kind_of: Array, default: []

attr_accessor :exists, :changed, :catgroup_exists

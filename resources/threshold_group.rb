# frozen_string_literal: true
require 'rexml/document'

actions :create
default_action :create

attribute :name, kind_of: String, name_attribute: true
attribute :rrd_repository, kind_of: String, default: '/var/opennms/rrd/snmp', required: true

attr_accessor :exists

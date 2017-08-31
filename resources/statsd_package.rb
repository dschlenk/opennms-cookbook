# frozen_string_literal: true
require 'rexml/document'

# Creates a package in $ONMS_HOME/etc/statsd-configuration.xml
# You don't define reports here but rather using the statsd_report
# LWRP and reference the name of one of these.

actions :create
default_action :create

attribute :package_name, kind_of: String, required: true, name_attribute: true
attribute :filter, kind_of: String

attr_accessor :exists

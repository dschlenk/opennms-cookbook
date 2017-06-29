# frozen_string_literal: true
require 'rexml/document'

actions :create
default_action :create

# name not used as the report's name if report_name is defined in case you want
# to use the same name in multiple packages in the same chef run.
attribute :name, kind_of: String, name_attribute: true
attribute :report_name, kind_of: String
attribute :package_name, kind_of: String, required: true
attribute :description, kind_of: String, required: true
# default is daily at 01:20:00. No validation is done (currently).
attribute :schedule, kind_of: String, default: '0 20 1 * * ?', required: true
# defaults to 30 days
attribute :retain_interval, kind_of: Integer, default: 2_592_000_000, required: true
attribute :status, kind_of: String, equal_to: %w(on off), default: 'on', required: true
# key/value string pairs
attribute :parameters, kind_of: Hash
# other option is BottomNAttributeStatisticVisitor
attribute :class_name, kind_of: String, default: 'org.opennms.netmgt.dao.support.TopNAttributeStatisticVisitor', required: true

attr_accessor :exists, :package_exists

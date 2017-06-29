# frozen_string_literal: true
require 'rexml/document'
actions :create, :delete
default_action :create

attribute :name, kind_of: String, name_attribute: true
attribute :status, kind_of: String, equal_to: %w(on off), required: true
attribute :writeable, kind_of: String, default: 'yes', equal_to: %w(yes no)
attribute :uei, kind_of: String, required: true
attribute :description, kind_of: String
attribute :rule, kind_of: String, default: "IPADDR != '0.0.0.0'", required: true
# jeff says this shouldn't be changed
# attribute :notice_queue, :kind_of => String
attribute :destination_path, kind_of: String, required: true
attribute :text_message, kind_of: String, required: true
attribute :subject, kind_of: String
attribute :numeric_message, kind_of: String
attribute :event_severity, kind_of: String
# string key/value pairs
attribute :params, kind_of: Hash
attribute :vbname, kind_of: String
attribute :vbvalue, kind_of: String

attr_accessor :exists, :changed

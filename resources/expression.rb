# frozen_string_literal: true
require 'rexml/document'

actions :create, :create_if_missing, :delete
default_action :create

attribute :name, kind_of: String, name_attribute: true
attribute :expression, kind_of: String
attribute :group, kind_of: String, default: 'mib2', required: true
attribute :relaxed, kind_of: [TrueClass, FalseClass], default: false
attribute :type, kind_of: String, equal_to: %w(high low relativeChange absoluteChange), default: 'high', required: true
attribute :description, kind_of: String
attribute :ds_type, kind_of: String, default: 'node', required: true
# required for new
attribute :value, kind_of: Float
# required for new
attribute :rearm, kind_of: Float
# will default to 1 for creates
attribute :trigger, kind_of: Integer
attribute :ds_label, kind_of: String
attribute :triggered_uei, kind_of: String
attribute :rearmed_uei, kind_of: String
# only relevent if resource filters present
attribute :filter_operator, kind_of: String, equal_to: %w(and or), default: 'or'
# Array of hashes with two keys each: 'field', 'filter'. Like:
# [{'field' => 'ifHighSpeed', 'filter' => '^[1-9]+[0-9]*$'}, ... ]
attribute :resource_filters, kind_of: Array

attr_accessor :exists, :group_exists, :ds_type_exists, :ueis_exist, :changed

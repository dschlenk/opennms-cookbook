# frozen_string_literal: true
require 'rexml/document'

actions :create
default_action :create

attribute :policy_name,  kind_of: String, name_attribute: true
attribute :class_name,   kind_of: String, required: true
attribute :foreign_source_name, kind_of: String
attribute :params, kind_of: Hash
attr_accessor :exists, :foreign_source_exists

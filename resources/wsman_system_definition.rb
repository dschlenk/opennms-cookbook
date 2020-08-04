# frozen_string_literal: true
require 'rexml/document'

actions :add, :remove
default_action :add

attribute :name, kind_of: String, name_attribute: true
attribute :groups, kind_of: Array, required: true

attr_accessor :system_def_exists, :groups_exist, :exists

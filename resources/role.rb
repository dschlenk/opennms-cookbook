# frozen_string_literal: true
require 'rexml/document'

actions :create
default_action :create

attribute :name, kind_of: String, name_attribute: true
attribute :membership_group, kind_of: String, required: true
attribute :supervisor, kind_of: String, required: true
attribute :description, kind_of: String

attr_accessor :exists, :group_exists, :supervisor_exists

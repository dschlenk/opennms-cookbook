# frozen_string_literal: true
require 'rexml/document'

actions :create
default_action :create

attribute :user_id, kind_of: String, name_attribute: true
attribute :full_name, kind_of: String
attribute :user_comments, kind_of: String
attribute :password, kind_of: String
attribute :password_salt, kind_of: [TrueClass, FalseClass], default: false, required: false
# Array of strings
attribute :duty_schedules, kind_of: Array

attr_accessor :exists

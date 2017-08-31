# frozen_string_literal: true
require 'rexml/document'

actions :create
default_action :create

attribute :name, kind_of: String, name_attribute: true
# Map name must exist in database
attribute :default_svg_map, kind_of: String
attribute :comments, kind_of: String
# Array of strings.  Users checked for existance
attribute :users, kind_of: Array
# Array of strings - validation not performed
attribute :duty_schedules, kind_of: Array

attr_accessor :exists, :users_exist, :map_exists

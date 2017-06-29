# frozen_string_literal: true
# For now, only supports create. Existance is determined by role_name, username and type.
# TODO:  An update action could be useful here to add new times to an existing role/user/type instance.
require 'rexml/document'

actions :create
default_action :create

attribute :name, kind_of: String, name_attribute: true
attribute :role_name, kind_of: String, required: true
attribute :username, kind_of: String, required: true
attribute :type, kind_of: String, equal_to: %w(specific daily weekly monthly), default: 'specific', required: true
# Array of hashes with the keys:
# begins, ends: either dd-MMM-yyyy HH:mm:ss or HH:mm:ss
# day: optional and must match the pattern (monday|tuesday|wednesday|thursday|friday|saturday|sunday|[1-3][0-9]|[1-9])
# The value of this is validated before convergence is attempted.
attribute :times, kind_of: Array, required: true

attr_accessor :exists, :role_exists, :user_in_group, :times_valid

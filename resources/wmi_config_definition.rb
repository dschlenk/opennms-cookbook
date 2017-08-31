# frozen_string_literal: true
require 'rexml/document'

actions :create, :delete, :create_if_missing
default_action :create

attribute :name, kind_of: String, name_attribute: true
attribute :retry_count, kind_of: Integer
attribute :timeout, kind_of: Integer
attribute :username, kind_of: String
attribute :domain, kind_of: String
attribute :password, kind_of: String
# 'begin' => 'IP', 'end' => 'IP'
attribute :ranges, kind_of: Hash
# Array of IP address strings
attribute :specifics, kind_of: Array
# Array of IPLIKE address strings ([0-9]{1,3}((,|-)[0-9]{1,3})*|\*)\.([0-9]{1,3}((,|-)[0-9]{1,3})*|\*)\.([0-9]{1,3}((,|-)[0-9]{1,3})*|\*)\.([0-9]{1,3}((,|-)[0-9]{1,3})*|\*)
attribute :ip_matches, kind_of: Array
attribute :position, kind_of: String, equal_to: %w(top bottom), default: 'bottom'

attr_accessor :exists, :different

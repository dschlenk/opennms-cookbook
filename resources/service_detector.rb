# frozen_string_literal: true
require 'rexml/document'

actions :create, :create_if_missing, :delete
default_action :create

# identity for purposes of exists determined by service_name and foreign_source_name
attribute :name, kind_of: String, name_attribute: true
attribute :service_name, kind_of: String
# required for create
attribute :class_name,   kind_of: String
attribute :foreign_source_name, kind_of: String
attribute :port,         kind_of: Integer
attribute :retry_count,  kind_of: Integer
attribute :timeout,      kind_of: Integer
# If this is a changed resource and action is create, the params specified will replace all existing.
# So even if you need to change just one param, you need to include the entire set for this detector.
attribute :params,       kind_of: Hash
attr_accessor :exists, :changed, :foreign_source_exists

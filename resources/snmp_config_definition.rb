# frozen_string_literal: true
require 'rexml/document'

actions :create, :create_if_missing, :delete
default_action :create

# not actually used anywhere, just needs to be unique in the resource collection
attribute :name, kind_of: String, name_attribute: true
# the following are element attributes - existance is determined by these attributes.
attribute :port, kind_of: Integer
attribute :retry_count, kind_of: Integer
attribute :timeout, kind_of: Integer
attribute :read_community, kind_of: String
attribute :write_community, kind_of: String
attribute :proxy_host, kind_of: String
attribute :version, kind_of: String, equal_to: %w(v1 v2c v3)
attribute :max_vars_per_pdu, kind_of: Integer
attribute :max_repetitions, kind_of: Integer
attribute :max_request_size, kind_of: Integer
attribute :security_name, kind_of: String
attribute :security_level, kind_of: Integer, equal_to: [1, 2, 3]
attribute :auth_passphrase, kind_of: String
attribute :auth_protocol, kind_of: String, equal_to: %w(MD5 SHA)
attribute :engine_id, kind_of: String
attribute :context_engine_id, kind_of: String
attribute :context_name, kind_of: String
attribute :privacy_passphrase, kind_of: String
attribute :privacy_protocol, kind_of: String, equal_to: %w(DES AES AES192 AES256)
attribute :enterprise_id, kind_of: String
# The following attributes are not considered for existance, but are merged during updates.
# 'beginIP' => 'endIP', ...
attribute :ranges, kind_of: Hash
# Array of IP address strings
attribute :specifics, kind_of: Array
# Array of IPLIKE address strings ([0-9]{1,3}((,|-)[0-9]{1,3})*|\*)\.([0-9]{1,3}((,|-)[0-9]{1,3})*|\*)\.([0-9]{1,3}((,|-)[0-9]{1,3})*|\*)\.([0-9]{1,3}((,|-)[0-9]{1,3})*|\*)
attribute :ip_matches, kind_of: Array
# append definition to top of file or bottom - the first definition to match an IP is used.
# Only used for create operations that result in a new definition - will not move existing definitions to the top or bottom.
attribute :position, kind_of: String, equal_to: %w(top bottom), default: 'bottom'

attr_accessor :exists, :different

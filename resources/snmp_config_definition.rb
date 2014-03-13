require 'rexml/document'

actions :create
default_action :create

attribute :name, :kind_of => String, :name_attribute => true
attribute :port, :kind_of => Fixnum
attribute :retry_count, :kind_of => Fixnum
attribute :timeout, :kind_of => Fixnum
attribute :read_community, :kind_of => String
attribute :write_community, :kind_of => String
attribute :proxy_host, :kind_of => String
attribute :version, :kind_of => String
attribute :max_vars_per_pdu, :kind_of => Fixnum
attribute :max_repetitions, :kind_of => Fixnum
attribute :max_request_size, :kind_of => Fixnum
attribute :security_name, :kind_of => String
attribute :security_level, :kind_of => Fixnum, :equal_to => [1,2,3]
attribute :auth_passphrase, :kind_of => String
attribute :auth_protocol, :kind_of => String, :equal_to => ['MD5', 'SHA']
attribute :engine_id, :kind_of => String
attribute :context_engine_id, :kind_of => String
attribute :context_name, :kind_of => String
attribute :privacy_passphrase, :kind_of => String
attribute :privacy_protocol, :kind_of => String, :equal_to => ['DES','AES','AES192','AES256']
attribute :enterprise_id, :kind_of => String
# 'begin' => 'IP', 'end' => 'IP'
attribute :ranges, :kind_of => Hash
# Array of IP address strings
attribute :specifics, :kind_of => Array
# Array of IPLIKE address strings ([0-9]{1,3}((,|-)[0-9]{1,3})*|\*)\.([0-9]{1,3}((,|-)[0-9]{1,3})*|\*)\.([0-9]{1,3}((,|-)[0-9]{1,3})*|\*)\.([0-9]{1,3}((,|-)[0-9]{1,3})*|\*)
attribute :ip_matches, :kind_of => Array

attr_accessor :exists

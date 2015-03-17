require 'rexml/document'

actions :create
default_action :create

attribute :ip_addr, :kind_of => String, :name_attribute => true
attribute :foreign_source_name, :kind_of => String, :required => true
attribute :foreign_id, :kind_of => String, :required => true
attribute :status, :kind_of => Fixnum
attribute :managed, :kind_of => [TrueClass, FalseClass]
attribute :snmp_primary, :kind_of => String, :equal_to => ["P","S","N"]
# sync the import. Re-runs discovery.
attribute :sync_import, :kind_of => [TrueClass, FalseClass], :default => false
# if the interface already exists, should we still sync?
attribute :sync_existing, :kind_of => [TrueClass, FalseClass], :default => false

attr_accessor :exists, :import_exists, :node_exists

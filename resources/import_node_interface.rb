# frozen_string_literal: true
require 'rexml/document'

actions :create
default_action :create

attribute :ip_addr, kind_of: String, name_attribute: true
attribute :foreign_source_name, kind_of: String, required: true
attribute :foreign_id, kind_of: String, required: true
attribute :status, kind_of: Integer
attribute :managed, kind_of: [TrueClass, FalseClass]
attribute :snmp_primary, kind_of: String, equal_to: %w(P S N)
# sync the import. Re-runs discovery.
attribute :sync_import, kind_of: [TrueClass, FalseClass], default: false
# if the interface already exists, should we still sync?
attribute :sync_existing, kind_of: [TrueClass, FalseClass], default: false
# If your imports take a long time to sync, you can fiddle with these
# to prevent convergence continuing before imports finish. One reason
# you might want to do this is if a service restart happens at the
# end of the converge before the syncs end, the pending syncs will
# never happen.
attribute :sync_wait_periods, kind_of: Integer, default: 30
attribute :sync_wait_secs, kind_of: Integer, default: 10

attr_accessor :exists, :import_exists, :node_exists

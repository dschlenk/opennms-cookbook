# frozen_string_literal: true
require 'rexml/document'

actions :create, :sync
default_action :create

# foreign_source must reference an existing foreign_source's name.
attribute :name, kind_of: String, name_attribute: true
attribute :foreign_source_name, kind_of: String, default: 'imported:'
attribute :sync_import, kind_of: [TrueClass, FalseClass], default: false
# If your imports take a long time to sync, you can fiddle with these
# to prevent convergence continuing before imports finish. One reason
# you might want to do this is if a service restart happens at the
# end of the converge before the syncs end, the pending syncs will
# never happen.
attribute :sync_wait_periods, kind_of: Integer, default: 30
attribute :sync_wait_secs, kind_of: Integer, default: 10

attr_accessor :exists, :foreign_source_exists

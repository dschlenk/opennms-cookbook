# frozen_string_literal: true
require 'rexml/document'

actions :create
default_action :create

attribute :name, kind_of: String, name_attribute: true
attribute :target_name, kind_of: String, required: true
attribute :destination_path_name, kind_of: String, required: true
attribute :commands, kind_of: Array, required: true
attribute :auto_notify, kind_of: String, equal_to: %w(on off)
attribute :interval, kind_of: String, default: '0s'
# whether this is a target or escalation target. Targets are sent after the initial delay whereas escalation targets are sent in order waiting the same delay period between each.
attribute :type, kind_of: String, equal_to: %w(target escalate), default: 'target'
# only valid for escalation targets
attribute :escalate_delay, kind_of: String

attr_accessor :exists, :destination_path_exists, :minimum_commands, :commands_exist, :delay_defined

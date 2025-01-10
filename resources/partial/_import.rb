include Opennms::Cookbook::Provision::ModelImportHttpRequest
include Opennms::XmlHelper
include Opennms::Rbac

unified_mode true
property :foreign_source_name, String, default: 'imported:', identity: true, required: true
property :sync_import, [TrueClass, FalseClass], default: false, desired_state: false
property :sync_wait_periods, Integer, default: 30, desired_state: false
property :sync_wait_secs, Integer, default: 10, desired_state: false


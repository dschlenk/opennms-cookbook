include Opennms::Cookbook::Provision::ModelImportHttpRequest
include Opennms::XmlHelper
include Opennms::Rbac

property :ip_addr, String, name_property: true
property :foreign_source_name, String
property :foreign_id, String
property :status, Integer
property :managed, [TrueClass, FalseClass]
property :snmp_primary, String, equal_to: %w(P S N)
# sync the import. Re-runs discovery.
property :sync_import, [TrueClass, FalseClass], default: false
# if the interface already exists, should we still sync?
property :sync_existing, [TrueClass, FalseClass], default: false
# If your imports take a long time to sync, you can fiddle with these
# to prevent convergence continuing before imports finish. One reason
# you might want to do this is if a service restart happens at the
# end of the converge before the syncs end, the pending syncs will
# never happen.
property :sync_wait_periods, Integer, default: 30
property :sync_wait_secs, Integer, default: 10

load_current_value do |new_resource|
  model_import = REXML::Document.new(model_import(new_resource.foreign_source_name).message).root unless model_import(new_resource.foreign_source_name).nil?
  current_value_does_not_exist! if model_import.nil?
  model_import_node_interface = REXML::Document.new(Opennms::Cookbook::Provision::ModelImport.new("#{new_resource.foreign_source_name}", "#{baseurl}/requisitions/#{new_resource.foreign_source_name}/nodes/#{new_resource.foreign_id}/interfaces/#{new_resource.ip_addr}").message) unless model_import.nil?
  current_value_does_not_exist! if model_import_node_interface.nil?
  Chef::Log.debug "Interface: #{model_import_node_interface}"
  interface = model_import_node_interface.elements["interface[@ip-addr = '#{new_resource.ip_addr}']"]
  current_value_does_not_exist! if interface.nil?
  status interface.attributes['status'] unless interface.attributes['status'].nil?
  managed interface.attributes['managed'] unless interface.attributes['managed'].nil?
  snmp_primary interface.attributes['snmp-primary'] unless interface.attributes['snmp-primary'].nil?
end

action_class do
  include Opennms::Cookbook::Provision::ModelImportHttpRequest
  include Opennms::XmlHelper
  include Opennms::Rbac
end

action :create do
  converge_if_changed do
    model_import = REXML::Document.new(model_import(new_resource.foreign_source_name).message).root unless model_import(new_resource.foreign_source_name).nil?
    current_value_does_not_exist! if model_import.nil?
    model_import_node_interface = REXML::Document.new(Opennms::Cookbook::Provision::ModelImport.new("#{new_resource.foreign_source_name}", "#{baseurl}/requisitions/#{new_resource.foreign_source_name}/nodes/#{new_resource.foreign_id}/interfaces/#{new_resource.ip_addr}").message) unless model_import.nil?
    current_value_does_not_exist! if model_import_node_interface.nil?
    Chef::Log.debug "Interface: #{model_import_node_interface}"
    interface = model_import_node_interface.elements["interface[@ip-addr = '#{new_resource.ip_addr}']"]
    current_value_does_not_exist! if import_node.nil?
    Chef::Log.debug "Interface: #{interface}"
    if interface.nil?
      i_el = model_import.add_element 'interface', 'ip-addr' => new_resource.ip_addr
      unless new_resource.status.nil?
        i_el.attributes['status'] = new_resource.status
      end
      unless new_resource.managed.nil?
        i_el.attributes['managed'] = new_resource.managed
      end
      unless new_resource.snmp_primary.nil?
        i_el.attributes['snmp-primary'] = new_resource.snmp_primary
      end
      model_import_node_interface_create(new_resource.foreign_source_name, new_resource.foreign_id, new_resource.ip_addr).message model_import.to_s
    else
      unless new_resource.status.nil?
        interface.attributes['status'] = new_resource.status
      end
      unless new_resource.managed.nil?
        interface.attributes['managed'] = new_resource.managed
      end
      unless new_resource.snmp_primary.nil?
        interface.attributes['snmp-primary'] = new_resource.snmp_primary
      end
      model_import_node_interface_create(new_resource.foreign_source_name, new_resource.foreign_id, new_resource.ip_addr).message model_import.to_s
    end
  end
end


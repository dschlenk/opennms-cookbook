use 'partial/_import'
unified_mode true

property :service_name, String, name_attribute: true
property :foreign_source_name, String, required: true
property :foreign_id, String, required: true
property :ip_addr, String, required: true
property :sync_import, [TrueClass, FalseClass], default: false
# If your imports take a long time to sync, you can fiddle with these
# to prevent convergence continuing before imports finish. One reason
# you might want to do this is if a service restart happens at the
# end of the converge before the syncs end, the pending syncs will
# never happen.
property :sync_wait_periods, kind_of: Integer, default: 30
property :sync_wait_secs, kind_of: Integer, default: 10

load_current_value do |new_resource|
  model_import = REXML::Document.new(model_import(new_resource.foreign_source_name).message).root unless model_import(new_resource.foreign_source_name).nil?
  current_value_does_not_exist! if model_import.nil?
  model_import = REXML::Document.new(Opennms::Cookbook::Provision::ModelImport.new("#{new_resource.foreign_source_name}", "#{baseurl}/requisitions/#{new_resource.foreign_source_name}/nodes/#{new_resource.foreign_id}").message)
  current_value_does_not_exist! if model_import.nil?
  node_el = model_import.elements["node[@foreign-id = '#{new_resource.foreign_id}']"] unless model_import.nil?
  interface = node_el.elements["interface[@ip-addr = '#{new_resource.name}']"] unless node_el.nil?
  current_value_does_not_exist! if interface.nil?
  unless interface.nil?
    service_name interface.elements["monitored-service[@service-name = '#{new_resource.service_name}']"]
  end
end

action_class do
  include Opennms::Cookbook::Provision::ModelImportHttpRequest
  include Opennms::XmlHelper
  include Opennms::Rbac
end

action :create do
  converge_if_changed do
    model_import_init(new_resource.foreign_source_name)
    model_import_root = REXML::Document.new(model_import(new_resource.foreign_source_name).message).root
    Chef::Application.fatal!("Missing requisition #{new_resource.foreign_source_name}.") unless model_import_root.nil?
    current_value_does_not_exist! if model_import_root.nil?
    model_import_root = REXML::Document.new(Opennms::Cookbook::Provision::ModelImport.new("#{new_resource.foreign_source_name}", "#{baseurl}/requisitions/#{new_resource.foreign_source_name}/nodes/#{new_resource.foreign_id}").message) if model_import_root.nil?
    current_value_does_not_exist! if model_import_root.nil?
    node_el = model_import_root.elements["node[@foreign-id = '#{new_resource.foreign_id}']"] unless model_import_root.nil?
    Chef::Application.fatal!("Missing node with foreign ID #{new_resource.foreign_id}.") unless node_el.nil?
    interface_el = node_el.elements["interface[@ip-addr = '#{new_resource.name}']"] unless node_el.nil?
    Chef::Application.fatal!("Missing interface #{new_resource.ip_addr}.") unless interface_el.nil?
    service = interface.elements["monitored-service[@service-name = '#{new_resource.service_name}']"] unless interface_el.nil?
    name = new_resource.name || new_resource.service_name
    if service.nil?
      i_el = REXML::Element.new('monitored-service')
      i_el.attributes['service-name'] = name
    else
      unless name.nil?
        service.attributes['service-name'] = name
      end
    end
    if !new_resource.sync_import.nil? && new_resource.sync_import
      model_import_sync(new_resource.foreign_source_name, true)
    end
  end
end


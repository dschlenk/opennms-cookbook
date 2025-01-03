include Opennms::Cookbook::Provision::ModelImportHttpRequest
include Opennms::XmlHelper
include Opennms::Rbac

property :ip_addr, String, name_property: true
property :foreign_source_name, String
property :foreign_id, String
property :status, Integer
property :managed, [TrueClass, FalseClass], default: false
property :snmp_primary, String, equal_to: %w(P S N)
property :sync_import, [TrueClass, FalseClass], default: false
property :sync_existing, [TrueClass, FalseClass], default: false
property :sync_wait_periods, Integer, default: 30
property :sync_wait_secs, Integer, default: 10


load_current_value do |new_resource|
  model_import = REXML::Document.new(model_import(new_resource.foreign_source_name).message).root unless model_import(new_resource.foreign_source_name).nil?
  model_import = REXML::Document.new(Opennms::Cookbook::Provision::ModelImport.new("#{new_resource.foreign_source_name}", "#{baseurl}/requisitions/#{new_resource.foreign_source_name}/nodes/#{new_resource.foreign_id}").message) if model_import.nil?
  node_el = model_import.elements["node[@foreign-id = '#{new_resource.foreign_id}']"] unless model_import.nil?
  interface = node_el.elements["interface[@ip-addr = '#{new_resource.name}']"] unless node_el.nil?
  current_value_does_not_exist! if interface.nil?
  status interface.attributes['status'] if  interface.attributes['status'].nil?
  managed interface.attributes['managed'] if interface.attributes['managed'].nil?
  snmp_primary interface.attributes['snmp-primary'] if interface.attributes['snmp-primary'].nil?
end

action_class do
  include Opennms::Cookbook::Provision::ModelImportHttpRequest
  include Opennms::XmlHelper
  include Opennms::Rbac
end

action :create do
  converge_if_changed do
    model_import_init(new_resource.foreign_source_name, "opennms_import_node_interface")
    model_import_root = REXML::Document.new(model_import(new_resource.foreign_source_name).message).root
    model_import_root = REXML::Document.new(Opennms::Cookbook::Provision::ModelImport.new("#{new_resource.foreign_source_name}", "#{baseurl}/requisitions/#{new_resource.foreign_source_name}/nodes/#{new_resource.foreign_id}").message) if model_import_root.nil?
    node_el = model_import_root.elements["node[@foreign-id = '#{new_resource.foreign_id}']"] unless model_import_root.nil?
    interface_el = node_el.elements["interface[@ip-addr = '#{new_resource.name}']"] unless node_el.nil?
    if interface_el.nil?
      i_el = REXML::Element.new('interface')
      i_el.attributes['ip-addr'] = new_resource.name
      unless new_resource.status.nil?
        i_el.attributes['status'] = new_resource.status
      end
      unless new_resource.managed.nil?
        i_el.attributes['managed'] = new_resource.managed
      end
      unless new_resource.snmp_primary.nil?
        i_el.attributes['snmp-primary'] = new_resource.snmp_primary
      end
      node_el.add_element i_el
    else
      unless new_resource.status.nil?
        interface_el.attributes['status'] = new_resource.status
      end
      unless new_resource.managed.nil?
        interface_el.attributes['managed'] = new_resource.managed
      end
      unless new_resource.snmp_primary.nil?
        interface_el.attributes['snmp-primary'] = new_resource.snmp_primary
      end
    end
    model_import(new_resource.foreign_source_name).message model_import_root.to_s

    if !new_resource.sync_import.nil? && new_resource.sync_import
      model_import_sync(new_resource.foreign_source_name, true)
    end
  end
end


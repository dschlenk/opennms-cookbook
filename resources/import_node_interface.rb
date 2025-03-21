use 'partial/_import_node'
unified_mode true

property :ip_addr, String, identity: true
property :foreign_id, String, required: true, identity: true
property :status, Integer
property :managed, [true, false], default: false
property :snmp_primary, String, equal_to: %w(P S N)
property :sync_existing, [true, false], default: false, desired_state: false

load_current_value do |new_resource|
  model_import = REXML::Document.new(model_import(new_resource.foreign_source_name).message).root unless model_import(new_resource.foreign_source_name).nil?
  Chef::Log.debug "Missing requisition #{new_resource.foreign_source_name}." unless model_import.nil?
  if model_import.nil?
    ro_model_import_init(new_resource.foreign_source_name, node['opennms']['properties']['jetty']['port'], admin_secret_from_vault('password'))
    model_import = REXML::Document.new(ro_model_import(new_resource.foreign_source_name).message).root
  end
  current_value_does_not_exist! if model_import.nil?
  node_el = model_import.elements["node[@foreign-id = '#{new_resource.foreign_id}']"] unless model_import.nil?
  interface = node_el.elements["interface[@ip-addr = '#{new_resource.name}']"] unless node_el.nil?
  current_value_does_not_exist! if interface.nil?
  unless interface.attributes['status'].nil?
    sym = 'status' if interface.attributes['status'].nil?
    status_value = interface.attributes['status']

    if new_resource.send(sym).is_a?(Integer)
      value = begin
        Integer(status_value)
              rescue
                status_value
      end
      send(sym, value)
    elsif interface.attributes['status'].nil?
      status interface.attributes['status']
    end
  end
  managed interface.attributes['managed'].eql?('true')
  snmp_primary interface.attributes['snmp-primary'] unless interface.attributes['snmp-primary'].nil?

  unless interface.elements['category'].nil?
    node_category = []
    interface.each_element('category') do |category|
      node_category.push category.attributes['name'].to_s
    end
    categories node_category
  end
  unless interface.elements['meta-data'].nil?
    meta_datas = []
    interface.each_element('meta-data') do |data|
      mdata = {}
      mdata['context'] = data['context']
      mdata['key'] = data['key']
      mdata['value'] = data['value']
      meta_datas.push(mdata)
    end
    meta_data meta_datas
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
    raise Chef::Exceptions::ValidationFailed "No requisition named #{new_resource.foreign_source_name} found. Create it with an opennms_import[#{new_resource.foreign_source_name}] resource." if model_import(new_resource.foreign_source_name).nil?
    model_import_root = REXML::Document.new(model_import(new_resource.foreign_source_name).message).root unless model_import(new_resource.foreign_source_name).nil?
    node_el = model_import_root.elements["node[@foreign-id = '#{new_resource.foreign_id}']"] unless model_import_root.nil?
    raise Chef::Exceptions::ValidationFailed "No node with foreign ID #{new_resource.foreign_id} found. Create one with an opennms_import_node resource." if node_el.nil?
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
      unless new_resource.categories.nil?
        new_resource.categories.each do |category|
          i_el.add_element 'category', 'name' => category
        end
      end
      unless new_resource.meta_data.nil?
        new_resource.meta_data.each do |metadata|
          i_el.add_element 'meta-data', 'context' => metadata['context'], 'key' => metadata['key'], 'value' => metadata['value']
        end
      end
      node_el.unshift i_el
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
      unless new_resource.categories.nil?
        interface_el.elements.delete_all 'category'
        b = interface_el.elements['meta-data'] if b.nil?
        new_resource.categories.each do |category|
          if b.nil?
            interface_el.add_element 'category', 'name' => category
          else
            c = REXML::Element.new('category')
            c.attributes['name'] = category
            interface_el.insert_before(b, c)
          end
        end
      end
      unless new_resource.meta_data.nil?
        interface_el.elements.delete_all 'meta-data'
        new_resource.meta_data.each do |metadata|
          interface_el.add_element 'meta-data', 'context' => metadata['context'], 'key' => metadata['key'], 'value' => metadata['value']
        end
      end
    end
    model_import(new_resource.foreign_source_name).message model_import_root.to_s
    if !new_resource.sync_import.nil? && new_resource.sync_import
      model_import_sync(new_resource.foreign_source_name, true)
    end
  end
end

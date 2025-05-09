use 'partial/_import_node'
unified_mode true

property :service_name, String, name_property: true
property :foreign_id, String, required: true, identity: true
property :ip_addr, String, required: true, identity: true

load_current_value do |new_resource|
  name = new_resource.service_name
  model_import_root = REXML::Document.new(model_import(new_resource.foreign_source_name).message).root unless model_import(new_resource.foreign_source_name).nil?
  if model_import_root.nil?
    ro_model_import_init(new_resource.foreign_source_name, node['opennms']['properties']['jetty']['port'], admin_secret_from_vault('password'))
    model_import_root = REXML::Document.new(ro_model_import(new_resource.foreign_source_name).message).root
  end
  current_value_does_not_exist! if model_import_root.nil?
  node_el = model_import_root.elements["node[@foreign-id = '#{new_resource.foreign_id}']"] unless model_import_root.nil?
  interface_el = node_el.elements["interface[@ip-addr = '#{new_resource.ip_addr}']"] unless node_el.nil?
  service = interface_el.elements["monitored-service[@service-name = '#{name}']"] unless interface_el.nil?
  current_value_does_not_exist! if service.nil?

  unless service.elements['category'].nil?
    node_category = []
    service.each_element('category') do |category|
      node_category.push category.attributes['name'].to_s
    end
    categories node_category
  end
  unless service.elements['asset'].nil?
    node_assets = {}
    service.each_element('asset') do |asset|
      node_assets[asset.attributes['key'].to_s] = asset.attributes['value'].to_s
    end
    assets node_assets
  end
  unless service.elements['meta-data'].nil?
    meta_datas = []
    service.each_element('meta-data') do |data|
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
    name = new_resource.service_name
    model_import_init(new_resource.foreign_source_name)
    raise Chef::Exceptions::ValidationFailed "No requisition named #{new_resource.foreign_source_name} found. Create it with an opennms_import[#{new_resource.foreign_source_name}] resource." if model_import(new_resource.foreign_source_name).nil?
    model_import_root = REXML::Document.new(model_import(new_resource.foreign_source_name).message).root
    node_el = model_import_root.elements["node[@foreign-id = '#{new_resource.foreign_id}']"]
    raise Chef::Exceptions::ValidationFailed "No node with foreign ID #{new_resource.foreign_id} found. Create one with an opennms_import_node resource." if node_el.nil?
    interface_el = node_el.elements["interface[@ip-addr = '#{new_resource.ip_addr}']"]
    raise Chef::Exceptions::ValidationFailed "No interface with IP #{new_resource.ip_addr} found. Create one with an opennms_import_node_interface resource." if interface_el.nil?
    service = interface_el.elements["monitored-service[@service-name = '#{name}']"]
    if service.nil?
      ms_el = REXML::Element.new('monitored-service')
      ms_el.attributes['service-name'] = name
      unless new_resource.categories.nil?
        new_resource.categories.each do |category|
          ms_el.add_element 'category', 'name' => category
        end
      end
      unless new_resource.meta_data.nil?
        new_resource.meta_data.each do |metadata|
          ms_el.add_element 'meta-data', 'context' => metadata['context'], 'key' => metadata['key'], 'value' => metadata['value']
        end
      end
      interface_el.add_element ms_el
    else
      unless new_resource.categories.nil?
        service.elements.delete_all 'category'
        # find the sibling to insert before
        b = service.elements['asset']
        b = service.elements['meta-data'] if b.nil?
        new_resource.categories.each do |category|
          if b.nil?
            service.add_element 'category', 'name' => category
          else
            c = REXML::Element.new('category')
            c.attributes['name'] = category
            service.insert_before(b, c)
          end
        end
      end
      unless new_resource.meta_data.nil?
        service.elements.delete_all 'meta-data'
        new_resource.meta_data.each do |metadata|
          service.add_element 'meta-data', 'context' => metadata['context'], 'key' => metadata['key'], 'value' => metadata['value']
        end
      end
    end
    model_import(new_resource.foreign_source_name).message model_import_root.to_s
    if !new_resource.sync_import.nil? && new_resource.sync_import
      model_import_sync(new_resource.foreign_source_name, true)
    end
  end
end

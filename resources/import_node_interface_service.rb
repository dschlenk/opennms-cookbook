use 'partial/_import'
unified_mode true

property :service_name, String, name_attribute: true
property :foreign_source_name, String, required: true
property :foreign_id, String, required: true
property :ip_addr, String, required: true, identity: true
property :sync_import, [TrueClass, FalseClass], default: false
# If your imports take a long time to sync, you can fiddle with these
# to prevent convergence continuing before imports finish. One reason
# you might want to do this is if a service restart happens at the
# end of the converge before the syncs end, the pending syncs will
# never happen.
property :sync_wait_periods, kind_of: Integer, default: 30
property :sync_wait_secs, kind_of: Integer, default: 10

load_current_value do |new_resource|
  name = new_resource.name || new_resource.service_name
  model_import_root = REXML::Document.new(model_import(new_resource.foreign_source_name).message).root unless model_import(new_resource.foreign_source_name).nil?
  model_import_root = REXML::Document.new(Opennms::Cookbook::Provision::ModelImport.new("#{new_resource.foreign_source_name}", "#{baseurl}/requisitions/#{new_resource.foreign_source_name}/nodes/#{new_resource.foreign_id}").message) if model_import_root.nil?
  current_value_does_not_exist! if model_import_root.nil?
  node_el = model_import_root.elements["node[@foreign-id = '#{new_resource.foreign_id}']"] unless model_import_root.nil?
  interface_el = node_el.elements["interface[@ip-addr = '#{new_resource.ip_addr}']"] unless node_el.nil?
  service = REXML::Document.new(Opennms::Cookbook::Provision::ModelImport.new("#{new_resource.foreign_source_name}", "#{baseurl}/requisitions/#{new_resource.foreign_source_name}/nodes/#{new_resource.foreign_id}//services/#{name}").message)
  service = interface_el.elements["monitored-service[@service-name = '#{name}']"] if  service.nil?
  current_value_does_not_exist! if service.nil?
  foreign_source_name new_resource.foreign_source_name
  foreign_id new_resource.foreign_id
  ip_addr new_resource.ip_addr
  service_name name
  node_assets = {}
  meta_datas = []
  meta_data = {}
  node_category = []

  unless service.elements['category'].nil?
    service.each_element('category') do |category|
      node_category.push category.attributes['name'].to_s
    end
    categories node_category
  end
  unless service.elements['asset'].nil?
    service.each_element('asset') do |asset|
      node_assets[asset.attributes['key'].to_s] = asset.attributes['value'].to_s
    end
    assets node_assets
  end
  unless service.elements['meta-data'].nil?
    service.each_element('meta-data') do |mdata|
      mdata.each do |key, value|
        meta_data[key.to_s] = value
      end
      meta_datas.push (meta_data)
      meta_data meta_datas
    end
  end
end

action_class do
  include Opennms::Cookbook::Provision::ModelImportHttpRequest
  include Opennms::XmlHelper
  include Opennms::Rbac
end

action :create do
  converge_if_changed do
    name = new_resource.name || new_resource.service_name
    model_import_init(new_resource.foreign_source_name)
    model_import_root = REXML::Document.new(model_import(new_resource.foreign_source_name).message).root unless model_import(new_resource.foreign_source_name).nil?
    model_import_root = REXML::Document.new(Opennms::Cookbook::Provision::ModelImport.new("#{new_resource.foreign_source_name}", "#{baseurl}/requisitions/#{new_resource.foreign_source_name}/nodes/#{new_resource.foreign_id}").message) if model_import_root.nil?
    current_value_does_not_exist! if model_import_root.nil?
    node_el = model_import_root.elements["node[@foreign-id = '#{new_resource.foreign_id}']"] unless model_import_root.nil?
    interface_el = node_el.elements["interface[@ip-addr = '#{new_resource.ip_addr}']"] unless node_el.nil?
    service = REXML::Document.new(Opennms::Cookbook::Provision::ModelImport.new("#{new_resource.foreign_source_name}", "#{baseurl}/requisitions/#{new_resource.foreign_source_name}/nodes/#{new_resource.foreign_id}//services/#{name}").message)
    service = interface_el.elements["monitored-service[@service-name = '#{name}']"] if  service.nil?
    if service.nil?
      ms_el = REXML::Element.new('monitored-service')
      ms_el.attributes['service-name'] = name
      if !new_resource.categories.nil?
        new_resource.categories.each do |category|
          ms_el.unshift 'category', 'name' => category
        end
      end
      unless new_resource.meta_data.nil?
        new_resource.meta_data.each do |metadata|
          metadata.each do |context, key, value|
            if key == 'context'
              ms_el.add_element 'meta-data', 'context' => context, 'key' => key, 'value' => value
            end
          end
        end
      end
      unless new_resource.assets.nil?
        new_resource.assets.each do |key, value|
          ms_el.add_element 'asset', 'name' => key, 'value' => value
        end
      end
      interface_el.unshift ms_el
    else
      unless name.nil?
        service.attributes['service-name'] = name
      end
      if !new_resource.categories.nil?
        new_resource.categories.each do |category|
          service.add_element 'category', 'name' => category
        end
      end
      unless new_resource.meta_data.nil?
        new_resource.meta_data.each do |metadata|
          metadata.each do |context, key, value|
            if key == 'context'
              service.add_element 'meta-data', 'context' => context, 'key' => key, 'value' => value
            end
          end
        end
      end
      unless new_resource.assets.nil?
        new_resource.assets.each do |key, value|
          service.add_element 'asset', 'name' => key, 'value' => value
        end
      end
    end
    if !new_resource.sync_import.nil? && new_resource.sync_import
      model_import_sync(new_resource.foreign_source_name, true)
    end
  end
end


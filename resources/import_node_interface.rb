use 'partial/_import'
unified_mode true

property :ip_addr, String, identity: true
property :foreign_source_name,  String, identity: true, required: true
property :foreign_id, String, required: true
property :status, Integer
property :managed, [TrueClass, FalseClass], default: false
property :snmp_primary, String, equal_to: %w(P S N)
property :sync_import, [TrueClass, FalseClass], default: false
property :sync_existing, [TrueClass, FalseClass], default: false
property :sync_wait_periods, Integer, default: 30
property :sync_wait_secs, Integer, default: 10

load_current_value do |new_resource|
  model_import = REXML::Document.new(model_import(new_resource.foreign_source_name).message).root unless model_import(new_resource.foreign_source_name).nil?
  Chef::Log.debug "Missing requisition #{new_resource.foreign_source_name}." unless model_import.nil?
  current_value_does_not_exist! if model_import.nil?
  model_import = REXML::Document.new(Opennms::Cookbook::Provision::ModelImport.new("#{new_resource.foreign_source_name}", "#{baseurl}/requisitions/#{new_resource.foreign_source_name}/nodes/#{new_resource.foreign_id}").message)
  Chef::Log.debug "Missing Node #{new_resource.foreign_source_name}." unless model_import.nil?
  current_value_does_not_exist! if model_import.nil?
  node_el = model_import.elements["node[@foreign-id = '#{new_resource.foreign_id}']"] unless model_import.nil?
  interface = node_el.elements["interface[@ip-addr = '#{new_resource.name}']"] unless node_el.nil?
  current_value_does_not_exist! if interface.nil?
  foreign_source_name new_resource.foreign_source_name
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
    else status interface.attributes['status'] if interface.attributes['status'].nil?
    end
  end
  node_assets = {}
  meta_datas = []
  meta_data = {}
  node_category = []
  managed interface.attributes['managed'] if interface.attributes['managed'].nil?
  snmp_primary interface.attributes['snmp-primary'] if interface.attributes['snmp-primary'].nil?

  unless import_node.elements['category'].nil?
    import_node.each_element('category') do |category|
      node_category.push category.attributes['name'].to_s
    end
    categories node_category
  end
  unless interface.elements['asset'].nil?
    interface.each_element('asset') do |asset|
      node_assets[asset.attributes['key'].to_s] = asset.attributes['value'].to_s
    end
    assets node_assets
  end
  unless interface.elements['meta-data'].nil?
    interface.each_element('meta-data') do |mdata|
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
    model_import_init(new_resource.foreign_source_name)
    model_import_root = REXML::Document.new(model_import(new_resource.foreign_source_name).message).root
    Chef::Application.fatal!("Missing requisition #{new_resource.foreign_source_name}.") if model_import_root.nil?
    current_value_does_not_exist! if model_import_root.nil?
    model_import_root = REXML::Document.new(Opennms::Cookbook::Provision::ModelImport.new("#{new_resource.foreign_source_name}", "#{baseurl}/requisitions/#{new_resource.foreign_source_name}/nodes/#{new_resource.foreign_id}").message) if model_import_root.nil?
    current_value_does_not_exist! if model_import_root.nil?
    node_el = model_import_root.elements["node[@foreign-id = '#{new_resource.foreign_id}']"] unless model_import_root.nil?
    Chef::Application.fatal!( "Missing node with foreign ID #{new_resource.foreign_id}.") unless node_el.nil?
    interface_el = node_el.elements["interface[@ip-addr = '#{new_resource.name}']"] unless node_el.nil?
    Chef::Log.debug "Missing requisition #{new_resource.foreign_source_name}." if interface_el.nil?
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
      if !new_resource.categories.nil?
        new_resource.categories.each do |category|
          i_el.add_element 'category', 'name' => category
        end
      end

      unless new_resource.assets.nil?
        new_resource.assets.each do |key, value|
          i_el.add_element 'asset', 'name' => key, 'value' => value
        end
      end
      unless new_resource.meta_data.nil?
        new_resource.meta_data.each do |metadata|
          metadata.each do |context, key, value|
            if key == 'context'
              i_el.add_element 'meta-data', 'context' => context, 'key' => key, 'value' => value
            end
          end
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
      if !new_resource.categories.nil?
        new_resource.categories.each do |category|
          interface_el.add_element 'category', 'name' => category
        end
      end

      unless new_resource.assets.nil?
        new_resource.assets.each do |key, value|
          interface_el.add_element 'asset', 'name' => key, 'value' => value
        end
      end
      unless new_resource.meta_data.nil?
        new_resource.meta_data.each do |metadata|
          metadata.each do |context, key, value|
            if key == 'context'
              interface_el.add_element 'meta-data', 'context' => context, 'key' => key, 'value' => value
            end
          end
        end
      end
    end
    model_import(new_resource.foreign_source_name).message model_import_root.to_s

    if !new_resource.sync_import.nil? && new_resource.sync_import
      model_import_sync(new_resource.foreign_source_name, true)
    end
  end
end


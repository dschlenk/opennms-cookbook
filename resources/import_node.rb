include Opennms::Cookbook::Provision::ModelImportHttpRequest
include Opennms::XmlHelper
include Opennms::Rbac

property :node_label, String
property :foreign_source_name, String
property :foreign_id, String
property :parent_foreign_source, String
property :parent_foreign_id, String
property :parent_node_label, String
property :city, String
property :building, String
property :categories, Array
property :assets, Hash, callbacks: { 'should be a hash with key/value pairs that are both strings' => lambda { |p| !p.any? { |k, v| !k.is_a?(String) || !v.is_a?(String) } }, }
property :sync_import, [TrueClass, FalseClass], default: false
property :sync_wait_periods, Integer, default: 30
property :sync_wait_secs, Integer, default: 10

load_current_value do |new_resource|
  node_assets = {}
  node_category = []
  model_import = REXML::Document.new(model_import(new_resource.foreign_source_name, "opennms_import").message).root unless model_import(new_resource.foreign_source_name, "opennms_import").nil?
  model_import = REXML::Document.new(Opennms::Cookbook::Provision::ModelImport.new("#{new_resource.foreign_source_name}", "#{baseurl}/requisitions/#{new_resource.foreign_source_name}/nodes/#{new_resource.foreign_id}").message) if model_import.nil?
  current_value_does_not_exist! if model_import.nil?
  import_node = model_import.elements["node [@node-label = '#{new_resource.name}' and @foreign-id = '#{new_resource.foreign_id}']"]
  current_value_does_not_exist! if import_node.nil?
  node_label import_node.attributes['node-label'] if import_node.attributes['node-label'].nil?
  foreign_id import_node.attributes['foreign-id'] if import_node.attributes['foreign-id'].nil?
  parent_foreign_source import_node.attributes['parent-foreign-source'] if import_node.attributes['parent-foreign-source'].nil?
  parent_foreign_id import_node.attributes['parent-foreign-id'] if import_node.attributes['parent-foreign-id'].nil?
  parent_node_label import_node.attributes['parent-node-label'] if import_node.attributes['parent-node-label'].nil?
  city import_node.attributes['city'] if !import_node.attributes['city'].nil?
  building import_node.attributes['building'] if !import_node.attributes['building'].nil?
  unless import_node.elements['category'].nil?
    import_node.each_element('category') do |category|
      node_category.push category.attributes['name'].to_s
    end
    categories node_category
  end
  unless import_node.elements['asset'].nil?
    import_node.each_element('asset') do |asset|
      node_assets[asset.attributes['key'].to_s] = asset.attributes['value'].to_s
    end
    assets node_assets
  end
end

action_class do
  include Opennms::Cookbook::Provision::ModelImportHttpRequest
  include Opennms::XmlHelper
  include Opennms::Rbac
end

action :create do
  converge_if_changed do
    model_import_init(new_resource.foreign_source_name, "opennms_import_node")
    model_import = REXML::Document.new(model_import(new_resource.foreign_source_name, "opennms_import_node").message).root
    model_import = REXML::Document.new(Opennms::Cookbook::Provision::ModelImport.new("#{new_resource.foreign_source_name}", "#{baseurl}/requisitions/#{new_resource.foreign_source_name}/nodes/#{new_resource.foreign_id}").message) if model_import.nil?
    import_node = model_import.elements["node [@node-label = '#{new_resource.name}' and @foreign-id = '#{new_resource.foreign_id}']"] unless model_import.nil?
    if import_node.nil?
      node_el = model_import.add_element 'node', 'node-label' => new_resource.name, 'foreign-id' => new_resource.foreign_id
      unless new_resource.parent_foreign_source.nil?
        node_el.attributes['parent-foreign-source'] = new_resource.parent_foreign_source
      end
      unless new_resource.parent_foreign_id.nil?
        node_el.attributes['parent-foreign-id'] = new_resource.parent_foreign_id
      end
      unless new_resource.parent_node_label.nil?
        node_el.attributes['parent-node-label'] = new_resource.parent_node_label
      end
      unless new_resource.city.nil?
        node_el.attributes['city'] = new_resource.city
      end
      unless new_resource.building.nil?
        node_el.attributes['building'] = new_resource.building
      end
      if !new_resource.categories.nil?
        new_resource.categories.each do |category|
          node_el.add_element 'category', 'name' => category
        end
      end
      unless new_resource.assets.nil?
        new_resource.assets.each do |key, value|
          node_el.add_element 'asset', 'name' => key, 'value' => value
        end
      end
    else
      import_node.attributes['node-label'] = new_resource.name
      import_node.attributes['foreign-id'] = new_resource.foreign_id
      unless new_resource.parent_foreign_source.nil?
        import_node.attributes['parent-foreign-source'] = new_resource.parent_foreign_source
      end
      unless new_resource.parent_foreign_id.nil?
        import_node.attributes['parent-foreign-id'] = new_resource.parent_foreign_id
      end
      unless new_resource.parent_node_label.nil?
        import_node.attributes['parent-node-label'] = new_resource.parent_node_label
      end
      unless new_resource.city.nil?
        import_node.attributes['city'] = new_resource.city
      end
      unless new_resource.building.nil?
        import_node.attributes['building'] = new_resource.building
      end
      if !new_resource.categories.nil?
        import_node.elements.delete_all 'category'
        new_resource.categories.each do |category|
          import_node.add_element 'category', 'name' => category
        end
      end

      unless new_resource.assets.nil?
        import_node.elements.delete_all 'asset'
        new_resource.assets.each do |key, value|
          import_node.add_element 'asset', 'name' => key, 'value' => value
        end
      end
    end
    model_import(new_resource.foreign_source_name, "opennms_import_node").message model_import.to_s
  end
end

action :delete do
  converge_if_changed do
    model_import = REXML::Document.new(model_import(new_resource.name, "opennms_import_node").message).root unless model_import(new_resource.name, "opennms_import_node").nil?
    import_node = model_import.elements["node [@node-label = '#{new_resource.name}' and @foreign-id = '#{new_resource.foreign_id}']"] unless model_import.nil?
    unless import_node.nil?
      model_import_node_delete(new_resource.foreign_source_name, new_resource.foreign_id)
    end
    if !new_resource.sync_import.nil? && new_resource.sync_import
      model_import_sync(new_resource.foreign_source_name, true)
    end
  end
end

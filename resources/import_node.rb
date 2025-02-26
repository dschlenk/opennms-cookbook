use 'partial/_import_node'
unified_mode true

property :node_label, String, name_property: true
property :foreign_id, String, identity: true, required: true
property :parent_foreign_source, String
property :parent_foreign_id, String
property :parent_node_label, String
property :city, String
property :building, String
property :assets, Hash, callbacks: { 'should be a hash with key/value pairs that are both strings' => ->(p) { !p.any? { |k, v| !k.is_a?(String) || !v.is_a?(String) } } }

load_current_value do |new_resource|
  model_import = REXML::Document.new(model_import(new_resource.foreign_source_name).message).root unless model_import(new_resource.foreign_source_name).nil?
  model_import = REXML::Document.new(Opennms::Cookbook::Provision::ModelImport.new("#{new_resource.foreign_source_name}", "#{baseurl}/requisitions/#{new_resource.foreign_source_name}/nodes/#{new_resource.foreign_id}").message) if model_import.nil?
  current_value_does_not_exist! if model_import.nil?
  import_node = model_import.elements["node[@foreign-id = '#{new_resource.foreign_id}']"]
  current_value_does_not_exist! if import_node.nil?
  node_label import_node.attributes['node-label']
  parent_foreign_source import_node.attributes['parent-foreign-source']
  parent_foreign_id import_node.attributes['parent-foreign-id']
  parent_node_label import_node.attributes['parent-node-label']
  city import_node.attributes['city']
  building import_node.attributes['building']
  unless import_node.elements['category'].nil?
    node_category = []
    import_node.each_element('category') do |category|
      node_category.push category.attributes['name'].to_s
    end
    categories node_category
  end
  unless import_node.elements['asset'].nil?
    node_assets = {}
    import_node.each_element('asset') do |asset|
      node_assets[asset.attributes['name'].to_s] = asset.attributes['value'].to_s
    end
    assets node_assets
  end
  unless import_node.elements['meta-data'].nil?
    meta_datas = []
    import_node.each_element('meta-data') do |data|
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
    model_import = REXML::Document.new(model_import(new_resource.foreign_source_name).message).root
    import_node = model_import.elements["node[@foreign-id = '#{new_resource.foreign_id}']"]
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
      unless new_resource.categories.nil?
        new_resource.categories.each do |category|
          node_el.add_element 'category', 'name' => category
        end
      end
      unless new_resource.assets.nil?
        new_resource.assets.each do |key, value|
          node_el.add_element 'asset', 'name' => key, 'value' => value
        end
      end
      unless new_resource.meta_data.nil?
        new_resource.meta_data.each do |metadata|
          node_el.add_element 'meta-data', 'context' => metadata['context'], 'key' => metadata['key'], 'value' => metadata['value']
        end
      end
    else
      import_node.attributes['node-label'] = new_resource.name
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
      unless new_resource.categories.nil?
        import_node.elements.delete_all 'category'
        # find the sibling to insert before
        b = import_node.elements['asset']
        b = import_node.elements['meta-data'] if b.nil?
        new_resource.categories.each do |category|
          if b.nil?
            import_node.add_element 'category', 'name' => category
          else
            c = REXML::Element.new('category')
            c.attributes['name'] = category
            import_node.insert_before(b, c)
          end
        end
      end

      unless new_resource.assets.nil?
        import_node.elements.delete_all 'asset'
        b = import_node.elements['meta-data']
        new_resource.assets.each do |key, value|
          if b.nil?
            import_node.add_element 'asset', 'name' => key, 'value' => value
          else
            a = REXML::Element.new('asset')
            a.attributes['name'] = key
            a.attributes['value'] = value
            import_node.insert_before(b, a)
          end
        end
      end

      unless new_resource.meta_data.nil?
        import_node.elements.delete_all 'meta-data'
        new_resource.meta_data.each do |metadata|
          import_node.add_element 'meta-data', 'context' => metadata['context'], 'key' => metadata['key'], 'value' => metadata['value']
        end
      end
    end
    Chef::Log.debug("model import message body now #{model_import.to_s}")
    model_import(new_resource.foreign_source_name).message model_import.to_s
    if !new_resource.sync_import.nil? && new_resource.sync_import
      model_import_sync(new_resource.foreign_source_name, true)
    end
  end
end

action :create_if_missing do
  model_import_init(new_resource.foreign_source_name)
  model_import = REXML::Document.new(model_import(new_resource.foreign_source_name).message).root
  model_import = REXML::Document.new(Opennms::Cookbook::Provision::ModelImport.new("#{new_resource.foreign_source_name}", "#{baseurl}/requisitions/#{new_resource.foreign_source_name}/nodes/#{new_resource.foreign_id}").message) if model_import.nil?
  import_node = model_import.elements["node [@node-label = '#{new_resource.name}' and @foreign-id = '#{new_resource.foreign_id}']"] unless model_import.nil?
  run_action(:create) if import_node.nil?
end

action :delete do
  converge_if_changed do
    model_import = REXML::Document.new(model_import(new_resource.name).message).root unless model_import(new_resource.name).nil?
    import_node = model_import.elements["node[@foreign-id = '#{new_resource.foreign_id}']"] unless model_import.nil?
    unless import_node.nil?
      model_import_node_delete(new_resource.foreign_source_name, new_resource.foreign_id)
    end
    if !new_resource.sync_import.nil? && new_resource.sync_import
      model_import_sync(new_resource.foreign_source_name, true)
    end
  end
end

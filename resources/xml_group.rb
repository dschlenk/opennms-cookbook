include Opennms::XmlHelper

unified_mode true

property :group_name, kind_of: String, name_property: true
property :source_url, kind_of: String, identity: true
property :collection_name, kind_of: String, identity: true
property :file, kind_of: String, identity: true, callbacks: {
  'should not be the empty string or start with a \'\.\' or \'\/\' character' => lambda { |p|
    !''.eql?(p) && !p.start_with?('.') && !p.start_with?('/') && p.end_with?('.xml')
  },
}
property :resource_type, kind_of: String, default: 'node'
property :resource_xpath, kind_of: String, required: true
property :key_xpath, kind_of: String
property :timestamp_xpath, kind_of: String
property :timestamp_format, kind_of: String
property :resource_keys, kind_of: Array, callbacks: {
  'should be an array of strings' => lambda { |p|
    !p.any? { |s| !s.is_a?(String) }
  },
}
# or [{ 'name' => object_name', 'type' => 'string|gauge|etc', 'xpath' => 'the/xpath' }, { ... }, ... ]
property :objects, kind_of: Array, default: [], callbacks: {
  'should be an array of hashes with keys `name`, `type`, and `xpath` (strings)' => lambda {
    |p| p.is_a?(Array) && !p.any? { |a| !a.is_a?(Hash) || !a.key?('name') || !a['name'].is_a?(String) || !a.key?('type') || !a['type'].is_a?(String) || !a.key?('xpath') || !a['xpath'].is_a?(String) }
  },
}

include Opennms::Cookbook::Collection::XmlCollectionTemplate
include Opennms::Cookbook::Collection::XmlCollectionGroupsTemplate
load_current_value do |new_resource|
  if new_resource.file
    r = groupsfile_resource(new_resource.file)
    if !r.nil?
      group = r.variables[:groupsfile].group(name: new_resource.group_name)
    else
      groupsfilename = "#{onms_etc}/xml-datacollection/#{new_resource.file}"
      current_value_does_not_exist! unless ::File.exist?(groupsfilename)
      group = Opennms::Cookbook::Collection::OpennmsCollectionXmlGroupsFile.read(groupsfilename).group(name: new_resource.group_name)
    end
  else
    r = xml_resource
    c = r.variables[:collections][new_resource.collection_name] unless r.nil?
    source = c.source(url: new_resource.source_url) unless c.nil?
    if r.nil? || c.nil? || source.nil?
      filename = "#{onms_etc}/xml-datacollection-config.xml"
      current_value_does_not_exist! unless ::File.exist?(filename)
      collection = Opennms::Cookbook::Collection::OpennmsCollectionConfigFile.read(filename, 'xml').collections[new_resource.collection_name]
      current_value_does_not_exist! if collection.nil?
      source = collection.source(url: new_resource.url)
    end
    current_value_does_not_exist! if source.nil?
    group = source.group(name: new_resource.group_name)
  end
  current_value_does_not_exist! if group.nil?
  resource_type group['resource_type']
  resource_xpath group['resource_xpath']
  key_xpath group['key_xpath'] if group.key?('key_xpath')
  timestamp_xpath group['timestamp_xpath'] if group.key?('key_xpath')
  timestamp_format group['timestamp_format'] if group.key?('timestamp_format')
  resource_keys group['resource_keys'] if group.key?('resource_keys')
  objects group['objects'] if group.key?('objects')
end

action_class do
  include Opennms::Cookbook::Collection::XmlCollectionTemplate
  include Opennms::Cookbook::Collection::XmlCollectionGroupsTemplate
  include Opennms::XmlHelper
  include Opennms::XmlGroupHelper
end

action :create do
  converge_if_changed do
    if !property_is_set?(:file)
      xml_resource_init
      collection = xml_resource.variables[:collections][new_resource.collection_name]
      raise Opennms::Cookbook::Collection::XmlCollectionDoesNotExist, "No xml-collection named #{new_resource.collection_name} found. Cannot add xml-source." if collection.nil?
      parent = collection.source(url: new_resource.source_url)
      raise Opennms::Cookbook::Collection::XmlSourceDoesNotExist, "No xml-source for url #{new_resource.source_url} in collection #{new_resource.collection_name} found. Cannot add xml-group #{new_resource.group_name}." if parent.nil?
    else
      groupsfile_resource_init(new_resource.file)
      parent = groupsfile_resource(new_resource.file).variables[:groupsfile]
    end
    group = parent.group(name: new_resource.group_name) unless parent.nil?
    if group.nil?
      group = { 'name' => new_resource.group_name, 'resource_type' => new_resource.resource_type, 'resource_xpath' => new_resource.resource_xpath }
      group['key_xpath'] = new_resource.key_xpath if property_is_set?(:key_xpath)
      group['timestamp_xpath'] = new_resource.timestamp_xpath if property_is_set?(:timestamp_xpath)
      group['timestamp_format'] = new_resource.timestamp_format if property_is_set?(:timestamp_format)
      group['resource_keys'] = new_resource.resource_keys if property_is_set?(:resource_keys)
      group['objects'] = objects_fixup(new_resource.objects) if property_is_set?(:objects)
      parent.groups.push(group)
    else
      run_action(:update)
    end
  end
end

action :create_if_missing do
  if !property_is_set?(:file)
    xml_resource_init
    collection = xml_resource.variables[:collections][new_resource.collection_name]
    raise Opennms::Cookbook::Collection::XmlCollectionDoesNotExist, "No xml-collection named #{new_resource.collection_name} found. Cannot add xml-source." if collection.nil?
    parent = collection.source(url: new_resource.source_url)
    raise Opennms::Cookbook::Collection::XmlSourceDoesNotExist, "No xml-source for url #{new_resource.source_url} in collection #{new_resource.collection_name} found. Cannot add xml-group #{new_resource.group_name}." if parent.nil?
  else
    groupsfile_resource_init(new_resource.file)
    parent = groupsfile_resource(new_resource.file).variables[:groupsfile]
  end
  group = parent.group(name: new_resource.group_name) unless parent.nil?
  run_action(:create) if group.nil?
end

action :update do
  converge_if_changed do
    if !property_is_set?(:file)
      xml_resource_init
      collection = xml_resource.variables[:collections][new_resource.collection_name]
      raise Opennms::Cookbook::Collection::XmlCollectionDoesNotExist, "No xml-collection named #{new_resource.collection_name} found. Cannot add xml-source." if collection.nil?
      parent = collection.source(url: new_resource.source_url)
      raise Opennms::Cookbook::Collection::XmlSourceDoesNotExist, "No xml-source for url #{new_resource.source_url} in collection #{new_resource.collection_name} found. Cannot add xml-group #{new_resource.group_name}." if parent.nil?
    else
      groupsfile_resource_init(new_resource.file)
      parent = groupsfile_resource(new_resource.file).variables[:groupsfile]
    end
    group = parent.group(name: new_resource.group_name) unless parent.nil?
    group['resource_type'] = new_resource.resource_type if property_is_set?(:resource_type)
    group['resource_xpath'] = new_resource.resource_xpath if property_is_set?(:resource_xpath)
    group['key_xpath'] = new_resource.key_xpath if property_is_set?(:key_xpath)
    group['timestamp_xpath'] = new_resource.timestamp_xpath if property_is_set?(:timestamp_xpath)
    group['timestamp_format'] = new_resource.timestamp_format if property_is_set?(:timestamp_format)
    group['resource_keys'] = new_resource.resource_keys if property_is_set?(:resource_keys)
    group['objects'] = objects_fixup(new_resource.objects) if property_is_set?(:objects)
  end
end

action :delete do
  if !property_is_set?(:file)
    xml_resource_init
    collection = xml_resource.variables[:collections][new_resource.collection_name]
    parent = collection.source(url: new_resource.source_url) unless collection.nil?
  else
    groupsfile_resource_init(new_resource.file)
    parent = groupsfile_resource(new_resource.file).variables[:groupsfile]
  end
  parent.groups.delete_if { |g| g['name'].eql?(new_resource.group_name) } unless parent.nil?
end

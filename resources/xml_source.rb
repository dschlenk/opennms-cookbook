# Defines data to collect in an XML collection in $ONMS_HOME/etc/xml-datacollection-config.xml.
# The collection_name must reference an existing collection defined by the opennms_xml_collection resource.
# Similar to SNMP, the xml-datacollection-config.xml file can be modularized.
# This cookbook supports either method using either the `import_groups` property of this resource (array of file names relative to $OPENNMS_HOME/etc/xml-datacollection) or use `opennms_xml_group` to define a group in the main file.
#
# If you'd like to load the import_groups files from a remote location rather than embedded in the cookbook, set the `import_groups_source` parameter to the base URL that each file in `import_groups` can be found.
# Set `import_groups_source` to `external` if you would like to manage deployment of the file(s) yourself.
# Leave `import_groups_source` as the default, `cookbook_file`, if your cookbook contains the file(s) to be deployed.
#
# Identity determined by url and collection_name

include Opennms::XmlHelper

unified_mode true

property :url, String, name_property: true
property :collection_name, String, required: true, identity: true
property :request_method, String
property :request_params, Hash
property :request_headers, Hash
property :request_content, String
property :request_content_type, String
property :import_groups, [Array, false], default: [], callbacks: {
  'should be an array of strings, or `false`' => lambda { |p|
    false.eql?(p) || !p.any? { |s| !s.is_a?(String) }
  },
}
property :import_groups_source, String, default: 'cookbook_file', desired_state: false
property :groups, [Array, false], default: [], callbacks: {
  'should be `false` (to remove any existing), or an array of hashes that each must contain keys `name`, `resource_type`, and `resource_xpath` (all strings); can contain `key_xpath`, `timestamp_xpath`, and `timestamp_format` (all strings), a key named `resource_keys` that if present its value must be an array of strings, and `objects` which if present its value must a hash with keys `name`, `type`, and `xpath` with string values.' => lambda {
    |p|
    false.eql?(p) ||
      !p.any? do |h|
        !h.is_a?(Hash) ||
          !h.key?('name') ||
          !h['name'].is_a?(String) ||
          !h.key?('resource_type') ||
          !h['resource_type'].is_a?(String) ||
          !h.key?('resource_xpath') ||
          !h['resource_xpath'].is_a?(String) ||
          (h.key?('key_xpath') && !h['key_xpath'].is_a?(String)) ||
          (h.key?('timestamp_xpath') &&
           !h['timestamp_xpath'].is_a?(String)) ||
          (h.key?('timestamp_format') &&
           !h['timestamp_format'].is_a?(String)) ||
          (h.key?('resource_keys') &&
           (!h['resource_keys'].is_a?(Array) ||
            h['resource_keys'].any? { |rk| !rk.is_a?(String) })) ||
          (h.key?('objects') && (!h['objects'].is_a?(Array) || h['objects'].any? { |oa| !oa.is_a?(Hash) || !oa.key?('name') || !oa['name'].is_a?(String) || !oa.key?('type') || !oa['type'].is_a?(String) || !oa.key?('xpath') || !oa['xpath'].is_a?(String) }))
      end
  },
}

include Opennms::Cookbook::Collection::XmlCollectionTemplate

load_current_value do |new_resource|
  r = xml_resource
  c = r.variables[:collections][new_resource.collection_name] unless r.nil?
  source = c.source(url: new_resource.url) unless c.nil?
  if r.nil? || c.nil? || source.nil?
    filename = "#{onms_etc}/xml-datacollection-config.xml"
    current_value_does_not_exist! unless ::File.exist?(filename)
    collection = Opennms::Cookbook::Collection::OpennmsCollectionConfigFile.read(filename, 'xml').collections[new_resource.collection_name]
    current_value_does_not_exist! if collection.nil?
    source = collection.source(url: new_resource.url)
  end
  current_value_does_not_exist! if source.nil?
  request_method source.request['method'] unless source.request.nil? || source.request['method'].nil?
  request_headers source.request['headers'] unless source.request.nil? || source.request['headers'].nil?
  request_params source.request['parameters'] unless source.request.nil? || source.request['parameters'].nil?
  request_content source.request['content'] unless source.request.nil? || source.request['content'].nil?
  request_content_type source.request['content_type'] unless source.request.nil? || source.request['content_type'].nil?
  import_groups source.import_groups
  groups source.groups
end

action_class do
  include Opennms::Cookbook::Collection::XmlCollectionTemplate
end

action :create do
  converge_if_changed do
    xml_resource_init
    collection = xml_resource.variables[:collections][new_resource.collection_name]
    raise Opennms::Cookbook::Collection::XmlCollectionDoesNotExist, "No xml-collection named #{new_resource.collection_name} found. Cannot add xml-source." if collection.nil?
    import_groups_resources
    source = collection.source(url: new_resource.url)
    if source.nil?
      collection.sources.push(Opennms::Cookbook::Collection::XmlSource.create(url: new_resource.url, import_groups: new_resource.import_groups, groups: new_resource.groups, request_method: new_resource.request_method, request_params: new_resource.request_params, request_headers: new_resource.request_headers, request_content: new_resource.request_content, request_content_type: new_resource.request_content_type))
    else
      run_action(:update)
    end
  end
end

action :create_if_missing do
  xml_resource_init
  collection = xml_resource.variables[:collections][new_resource.collection_name]
  raise Opennms::Cookbook::Collection::XmlCollectionDoesNotExist, "No xml-collection named #{new_resource.collection_name} found. Cannot add xml-source." if collection.nil?
  import_groups_resources
  source = collection.source(url: new_resource.url)
  run_action(:create) if source.nil?
end

action :update do
  import_groups_resources
  converge_if_changed(:request_method, :request_headers, :request_params, :request_content, :request_content_type, :import_groups, :groups) do
    xml_resource_init
    collection = xml_resource.variables[:collections][new_resource.collection_name]
    raise Opennms::Cookbook::Collection::XmlCollectionDoesNotExist, "No xml-collection named #{new_resource.collection_name} found. Cannot add xml-source." if collection.nil?
    source = collection.source(url: new_resource.url)
    source.update(request_method: new_resource.request_method, request_headers: new_resource.request_headers, request_params: new_resource.request_params, request_content: new_resource.request_content, request_content_type: new_resource.request_content_type, import_groups: new_resource.import_groups, groups: new_resource.groups)
  end
end

action :delete do
  delete_import_groups_files
  xml_resource_init
  collection = xml_resource.variables[:collections][new_resource.collection_name]
  unless collection.nil?
    source = collection.source(url: new_resource.url)
    converge_by("Removing xml-source with url #{new_resource.url} from xml-collection #{new_resource.collection_name}") do
      collection.sources.delete(source)
    end unless source.nil?
  end
end

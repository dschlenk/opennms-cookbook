# Defines data to be collected in a JMX collection in
# $ONMS_HOME/etc/jmx-datacollection-config.xml. The collection_name must
# reference an existing collection defined with the jmx_collection LWRP.

unified_mode true

include Opennms::XmlHelper
include Opennms::Cookbook::Collection::JmxCollectionTemplate

property :mbean_name, String, name_property: true
property :collection_name, String, required: true, identity: true
property :objectname, String, required: true, identity: true
property :keyfield, String
property :exclude, String
property :key_alias, String
property :resource_type, String
# hash of form: { 'name' => { 'alias' => 'theAlias', 'type' => 'gauge|string|etc'[,'data_source_name' => 'theDataSourceName] }, ... }
property :attribs, Hash, default: {}, callbacks: {
  'should be a Hash with string keys that represent the name field of each attrib and the value is a Hash with keys `alias` (string, required), `type` (string matching regex `([Cc](ounter|OUNTER)(32|64)?|[Gg](auge|AUGE)(32|64)?|[Tt](ime|IME)[Tt](icks|ICKS)|[Ii](nteger|NTEGER)(32|64)?|[Oo](ctet|CTET)[Ss](tring|TRING))`, required), `maxval` (string, optional), `minval (string, optional)' => lambda { |p|
    !p.any? { |k, v| !k.is_a?(String) || !v.is_a?(Hash) || !v.key?('alias') || !v['alias'].is_a?(String) || !v.key?('type') || !v['type'].match(/([Cc](ounter|OUNTER)(32|64)?|[Gg](auge|AUGE)(32|64)?|[Tt](ime|IME)[Tt](icks|ICKS)|[Ii](nteger|NTEGER)(32|64)?|[Oo](ctet|CTET)[Ss](tring|TRING))/) || (v.key?('maxval') && !v['maxval'].is_a?(String)) || (v.key?('minval') && !v['minval'].is_a?(String)) }
  },
}
property :include_mbeans, Array, default: [], callbacks: {
  'should be an array of strings' => lambda { |p|
    !p.any? { |s| !s.is_a?(String) }
  },
}
property :comp_attribs, Hash, default: {}, callbacks: {
  'should be a Hash with string keys that represent the name field of each comp-attrib and the value is a Hash with key `type` (a String matching `[Cc](omposite|OMPOSITE)`, required),  `comp_members` (a Hash where the key (a String) is the name of the comp-member and the value is in the same format as the `attribs` hash values except `alias` is optional), and optional key `alias` (String)' => lambda { |p|
    !p.any? { |k, v| !k.is_a?(String) || !v.key?('type') || !v['type'].match(/[Cc](omposite|OMPOSITE)/) || (v.key?('alias') && !v['alias'].is_a?(String)) || (v.key?('comp_members') && (!v['comp_members'].is_a?(Hash) || v['comp_members'].any? { |mk, mv| !mk.is_a?(String) || !mv.is_a?(Hash) || (mv.key?('alias') && !mv['alias'].is_a?(String)) || !mv.key?('type') || !mv['type'].match(/([Cc](ounter|OUNTER)(32|64)?|[Gg](auge|AUGE)(32|64)?|[Tt](ime|IME)[Tt](icks|ICKS)|[Ii](nteger|NTEGER)(32|64)?|[Oo](ctet|CTET)[Ss](tring|TRING))/) || (mv.key?('maxval') && !mv['maxval'].is_a?(String)) || (mv.key?('minval') && !mv['minval'].is_a?(String)) })) }
  },
}

load_current_value do |new_resource|
  r = jmx_resource
  collection = r.variables[:collections][new_resource.collection_name] unless r.nil?
  if r.nil? || collection.nil?
    filename = "#{onms_etc}/jmx-datacollection-config.xml"
    current_value_does_not_exist! unless ::File.exist?(filename)
    collection = Opennms::Cookbook::Collection::OpennmsCollectionConfigFile.read(filename, 'jmx').collections[new_resource.collection_name]
  end
  current_value_does_not_exist! if collection.nil?
  mbean = collection.mbean(name: new_resource.mbean_name, objectname: new_resource.objectname)
  current_value_does_not_exist! if mbean.nil?
  %i(keyfield exclude key_alias resource_type attribs include_mbeans comp_attribs).each do |p|
    send(p, mbean.send(p))
  end
end

action_class do
  include Opennms::XmlHelper
  include Opennms::Cookbook::Collection::JmxCollectionTemplate
end

action :create do
  converge_if_changed do
    jmx_resource_init
    collection = jmx_resource.variables[:collections][new_resource.collection_name]
    raise Opennms::Cookbook::Collection::NoSuchCollection, "No JMX collection named #{new_resource.collection_name}, cannot add jmx_mbean to it." if collection.nil?
    mbean = collection.mbean(name: new_resource.mbean_name, objectname: new_resource.objectname)
    if mbean.nil?
      resource_properties = %i(objectname keyfield exclude key_alias resource_type attribs include_mbeans comp_attribs).map { |p| [p, new_resource.send(p)] }.to_h.compact
      resource_properties[:name] = new_resource.mbean_name
      collection.mbeans.push(Opennms::Cookbook::Collection::JmxMBean.new(**resource_properties))
    else
      run_action(:update)
    end
  end
end

action :create_if_missing do
  jmx_resource_init
  collection = jmx_resource.variables[:collections][new_resource.collection_name]
  raise Opennms::Cookbook::Collection::NoSuchCollection, "No JMX collection named #{new_resource.collection_name}, cannot add jmx_mbean to it." if collection.nil?
  mbean = collection.mbean(name: new_resource.mbean_name, objectname: new_resource.objectname)
  run_action(:create) if mbean.nil?
end

action :update do
  converge_if_changed(:keyfield, :exclude, :key_alias, :resource_type, :attribs, :include_mbeans, :comp_attribs) do
    jmx_resource_init
    collection = jmx_resource.variables[:collections][new_resource.collection_name]
    mbean = collection.mbean(name: new_resource.mbean_name, objectname: new_resource.objectname)
    raise Chef::Exceptions::CurrentValueDoesNotExist if mbean.nil?
    resource_properties = %i(keyfield exclude key_alias resource_type attribs include_mbeans comp_attribs).map { |p| [p, new_resource.send(p)] }.to_h.compact
    mbean.update(**resource_properties)
  end
end

action :delete do
  jmx_resource_init
  collection = jmx_resource.variables[:collections][new_resource.collection_name]
  mbean = collection.mbean(name: new_resource.mbean_name, objectname: new_resource.objectname) unless collection.nil?
  unless mbean.nil?
    converge_by("Removing jmx_mbean #{new_resource.mbean_name} / #{new_resource.objectname} from collection #{new_resource.collection_name}") do
      collection.mbeans.delete_if { |q| q.name.eql?(new_resource.mbean_name) && q.objectname.eql?(new_resource.objectname) }
    end
  end
end

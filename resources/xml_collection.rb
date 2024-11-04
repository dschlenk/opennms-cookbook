# Defines a collection in $ONMS_HOME/etc/xml-datacollection-config.xml.
# Will be used by any packages in $ONMS_HOME/etc/collectd-configuration.xml
# that have a XML service with this collection name as the collection
# parameter value. You can use the xml_collection_service LWRP to create
# that service, the collection_package LWRP to define the package and the
# xml_source LWRP to define the data to collect in this xml_collection.

unified_mode true
use 'partial/_collection'

include Opennms::Cookbook::Collection::XmlCollectionTemplate

load_current_value do |new_resource|
  r = xml_resource
  collection = r.variables[:collections][new_resource.collection] unless r.nil?
  if r.nil? || collection.nil?
    filename = "#{onms_etc}/xml-datacollection-config.xml"
    current_value_does_not_exist! unless ::File.exist?(filename)
    collection = Opennms::Cookbook::Collection::OpennmsCollectionConfigFile.read(filename, 'xml').collections[new_resource.collection]
  end
  current_value_does_not_exist! if collection.nil?
  rrd_step collection.rrd_step
  rras collection.rras
end

action_class do
  include Opennms::Cookbook::Collection::XmlCollectionTemplate
end

action :create do
  converge_if_changed do
    xml_resource_init
    collection = xml_resource.variables[:collections][new_resource.collection]
    if collection.nil?
      resource_properties = %i(name rrd_step rras).map { |p| [p, new_resource.send(p)] }.to_h.compact
      collection = Opennms::Cookbook::Collection::XmlCollection.new(**resource_properties)
      xml_resource.variables[:collections][new_resource.collection] = collection
    else
      run_action(:update)
    end
  end
end

action :update do
  converge_if_changed(:rrd_step, :rras) do
    xml_resource_init
    collection = xml_resource.variables[:collections][new_resource.collection]
    raise Chef::Exceptions::CurrentValueDoesNotExist if collection.nil?
    collection.update(rrd_step: new_resource.rrd_step, rras: new_resource.rras)
  end
end

action :delete do
  xml_resource_init
  collection = xml_resource.variables[:collections][new_resource.collection]
  unless collection.nil?
    converge_by("Removing xml_collection #{new_resource.collection}") do
      xml_resource.variables[:collections].delete(new_resource.collection)
    end
  end
end

include Opennms::XmlHelper
include Opennms::Cookbook::Collection::CollectdTemplate

unified_mode true

use 'partial/_collection_service'
use 'partial/_collection_service_j'

property :factory, String
property :username, String
property :port, [String, Integer], deprecated: 'Support for this property is deprecated, as the `url` property functionally overrides it.'
property :protocol, String, deprecated: 'Support for this property is deprecated, as the `url` property functionally overrides it.'
property :url_path, String, deprecated: 'Support for this property is deprecated, as the `url` property functionally overrides it.'
property :rmi_server_port, [String, Integer], deprecated: 'Support for this property is deprecated, as the `url` property functionally overrides it.'
property :remote_jmx, [TrueClass, FalseClass, String], deprecated: 'Support for this property is deprecated, as the `url` property functionally overrides it.'
property :rrd_base_name, String
property :ds_name, String
property :friendly_name, String
property :class_name, String, default: 'org.opennms.netmgt.collectd.Jsr160Collector'

action :create do
  converge_if_changed do
    collectd_resource_init
    package = collectd_resource.variables[:collectd_config].packages[new_resource.package_name]
    service = package.service(service_name: new_resource.service_name)
    if service.nil?
      resource_properties = %i(service_name interval user_defined status collection timeout retry_count port parameters thresholding_enabled).map { |p| [p, new_resource.send(p)] }.to_h
      resource_properties[:interval] = 300000 if new_resource.interval.nil?
      resource_properties[:user_defined] = false if new_resource.user_defined.nil?
      resource_properties[:status] = 'on' if new_resource.status.nil?
      resource_properties[:thresholding_enabled] = false if new_resource.thresholding_enabled.nil?
      resource_properties[:port] = '1099' if new_resource.port.nil? && new_resource.url.nil?
      resource_properties[:collection] = 'default' if !resource_properties.key?(:collection) && new_resource.collection.nil? && (new_resource.parameters.nil? || new_resource.parameters['collection'].nil?)
      resource_properties[:parameters] = {} if !resource_properties.key?(:parameters) || resource_properties[:parameters].nil?
      resource_properties[:parameters]['username'] = new_resource.username unless new_resource.username.nil?
      resource_properties[:parameters]['password'] = new_resource.password unless new_resource.password.nil?
      resource_properties[:parameters]['factory'] = new_resource.factory unless new_resource.factory.nil?
      resource_properties[:parameters]['protocol'] = new_resource.protocol unless new_resource.protocol.nil? || !new_resource.url.nil?
      resource_properties[:parameters]['protocol'] = 'rmi' if resource_properties[:parameters]['protocol'].nil? && new_resource.url.nil?
      resource_properties[:parameters]['url'] = new_resource.url unless new_resource.url.nil?
      resource_properties[:parameters]['urlPath'] = new_resource.url_path unless new_resource.url_path.nil? || !new_resource.url.nil?
      resource_properties[:parameters]['urlPath'] = '/jmxrmi' if resource_properties[:parameters]['urlPath'].nil? && new_resource.url.nil?
      resource_properties[:parameters]['rmiServerPort'] = new_resource.rmi_server_port unless new_resource.rmi_server_port.nil? || !new_resource.url.nil?
      resource_properties[:parameters]['remoteJMX'] = new_resource.remote_jmx unless new_resource.remote_jmx.nil? || !new_resource.url.nil?
      resource_properties[:parameters]['rrd-base-name'] = new_resource.rrd_base_name unless new_resource.rrd_base_name.nil?
      resource_properties[:parameters]['rrd-base-name'] = 'java' if resource_properties[:parameters]['rrd-base-name'].nil?
      resource_properties[:parameters]['ds-name'] = new_resource.ds_name unless new_resource.ds_name.nil?
      resource_properties[:parameters]['friendly-name'] = new_resource.friendly_name unless new_resource.friendly_name.nil?
      resource_properties.compact!
      service = Opennms::Cookbook::Package::CollectdService.new(**resource_properties)
      # we need to set the type in case another resource updates us later in the run list
      service.type = Opennms::Cookbook::Package::CollectdService.type_from_class_name(new_resource.class_name)
      collectd_resource.variables[:collectd_config].packages[new_resource.package_name].services.push(service)
      collectd_resource.variables[:collectd_config].collectors.push({ 'service' => new_resource.service_name, 'class_name' => new_resource.class_name, 'parameters' => new_resource.class_parameters })
    else
      run_action(:update)
    end
  end
end

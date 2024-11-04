include Opennms::XmlHelper
include Opennms::Cookbook::Collection::CollectdTemplate

unified_mode true
use 'partial/_collection_service'
use 'partial/_collection_service_j'

property :driver, String
property :driver_file, String
property :user, String
property :class_name, String, default: 'org.opennms.netmgt.collectd.JdbcCollector'

action :create do
  declare_resource(:cookbook_file, "#{new_resource.driver_file}_#{new_resource.service_name}") do
    source new_resource.driver_file
    path "#{node['opennms']['conf']['home']}/lib/#{new_resource.driver_file}"
    mode '0664'
    owner node['opennms']['username']
    group node['opennms']['groupname']
    notifies :restart, 'service[opennms]'
  end unless new_resource.driver_file.nil?
  converge_if_changed do
    collectd_resource_init
    package = collectd_resource.variables[:collectd_config].packages[new_resource.package_name]
    service = package.service(service_name: new_resource.service_name)
    if service.nil?
      resource_properties = %i(service_name interval user_defined status collection timeout retry_count port parameters thresholding_enabled).map { |p| [p, new_resource.send(p)] }.to_h.compact
      resource_properties[:interval] = 300000 if new_resource.interval.nil?
      resource_properties[:user_defined] = false if new_resource.user_defined.nil?
      resource_properties[:status] = 'on' if new_resource.status.nil?
      resource_properties[:thresholding_enabled] = false if new_resource.thresholding_enabled.nil?
      resource_properties[:collection] = 'default' if !resource_properties.key?(:collection) && new_resource.collection.nil? && (new_resource.parameters.nil? || new_resource.parameters['collection'].nil?)
      resource_properties[:parameters] = {} if !resource_properties.key?(:parameters) || resource_properties[:parameters].nil?
      resource_properties[:parameters]['user'] = new_resource.user unless new_resource.user.nil?
      resource_properties[:parameters]['password'] = new_resource.password unless new_resource.password.nil?
      resource_properties[:parameters]['url'] = new_resource.url unless new_resource.url.nil?
      resource_properties[:parameters]['driver'] = new_resource.driver unless new_resource.driver.nil?
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

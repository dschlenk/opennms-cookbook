include Opennms::Cookbook::Provision::ForeignSourceHttpRequest
include Opennms::XmlHelper
include Opennms::Rbac
require 'nokogiri'

property :service_name, String, name_property: true
property :class_name, String
property :foreign_source_name, String, identity: true
property :parameters, Hash, callbacks: { 'should be a hash with key/value pairs that are both strings' => ->(p) { !p.any? { |k, v| !k.is_a?(String) || !v.is_a?(String) } } }

load_current_value do |new_resource|
  foreign_source = Nokogiri::XML(fs_resource(new_resource.foreign_source_name).message).remove_namespaces!.root unless fs_resource(new_resource.foreign_source_name).nil?
  if foreign_source.nil?
    ro_fs_resource_init(new_resource.foreign_source_name, node['opennms']['properties']['jetty']['port'], admin_secret_from_vault('password'))
    foreign_source = Nokogiri::XML(ro_fs_resource(new_resource.foreign_source_name).message).remove_namespaces!.root
  end
  current_value_does_not_exist! if foreign_source.nil?
  sd_el = foreign_source.xpath("/foreign-source/detectors/detector[@name = '#{new_resource.service_name}']")[0]
  current_value_does_not_exist! if sd_el.nil?
  fs_detector = foreign_source.xpath("/foreign-source/detectors/detector[@name = '#{new_resource.service_name}']")[0]
  current_value_does_not_exist! if fs_detector.nil?
  fs_params = {}
  class_name fs_detector.attribute('class').value unless fs_detector.attribute('class').nil?
  fs_detector.xpath('parameter').each do |parameter|
    fs_params[parameter.attribute('key').value] = parameter.attribute('value').value
  end
  parameters fs_params
end

action_class do
  include Opennms::Cookbook::Provision::ForeignSourceHttpRequest
  include Opennms::XmlHelper
  include Opennms::Rbac
  require 'nokogiri'
end

action :create do
  converge_if_changed do
    fs_resource_init(new_resource.foreign_source_name)
    service_name = new_resource.service_name
    foreign_source = Nokogiri::XML(fs_resource(new_resource.foreign_source_name).message).remove_namespaces!.root
    raise Chef::Exceptions::ValidationFailed "No foreign source definition named #{new_resource.foreign_source_name} found. Create it with an opennms_foreign_source[#{new_resource.foreign_source_name}] resource." if foreign_source.nil?
    detector = foreign_source.xpath("/foreign-source/detectors/detector[@name = '#{service_name}']")[0]
    if detector.nil?
      detectors_el = foreign_source.xpath('/foreign-source/detectors')[0]
      if detectors_el.nil?
        detectors_el = foreign_source.add_child('<detectors/>')[0]
      end
      # Create detector element and add the name attributes and class attribute
      detector_el = detectors_el.add_child("<detector name=#{service_name.encode(:xml => :attr)}#{new_resource.class_name.nil? ? '' : " class=#{new_resource.class_name.encode(:xml => :attr)}"}/>")[0]
      unless new_resource.parameters.nil?
        new_resource.parameters.each do |key, value|
          detector_el.add_child("<parameter key=#{key.encode(:xml => :attr)} value=#{value.encode(:xml => :attr)}/>")
        end
      end
      # then add the element to foreign_source.elements["/detectors"]
    else # one already exists, so you need to maybe update class
      unless new_resource.class_name.nil?
        detector.attribute('class').value = new_resource.class_name
      end
      # delete all parameters
      detector.xpath('parameter').each do |p|
        p.remove
      end
      # Add all parameter back with new values
      new_resource.parameters.each do |key, value|
        detector.add_child("<parameter key=#{key.encode(:xml => :attr)} value=#{value.encode(:xml => :attr)}/>")
      end unless new_resource.parameters.nil?
    end
    # update fs_resource.message with foreign_source.to_s
    fs_resource(new_resource.foreign_source_name).message foreign_source.to_s
  end
end

action :create_if_missing do
  converge_if_changed do
    fs_resource_init(new_resource.foreign_source_name)
    service_name = new_resource.service_name
    foreign_source = Nokogiri::XML(fs_resource(new_resource.foreign_source_name).message).remove_namespaces!.root
    detector = foreign_source.xpath("detectors/detector[@name = '#{service_name}']")[0] unless foreign_source.nil?
    if detector.nil?
      run_action(:create)
    end
  end
end

action :delete do
  foreign_source = Nokogiri::XML(fs_resource(new_resource.foreign_source_name).message).remove_namespaces!.root unless fs_resource(new_resource.foreign_source_name).nil?
  foreign_source = Nokogiri::XML(Opennms::Cookbook::Provision::ForeignSource.new(new_resource.foreign_source_name, "#{baseurl}/foreignSources/#{new_resource.foreign_source_name}").message).remove_namespaces!.root if foreign_source.nil?
  service_name = new_resource.service_name
  detector = foreign_source.xpath("/foreign-source/detectors/detector[@name = '#{service_name}']")[0] unless foreign_source.nil?
  unless detector.nil?
    converge_by("Removing service detector #{service_name} from foreign source #{new_resource.foreign_source_name}") do
      if fs_resource(new_resource.foreign_source_name).nil?
        fs_resource_init(new_resource.foreign_source_name)
        foreign_source = Nokogiri::XML(fs_resource(new_resource.foreign_source_name).message).remove_namespaces!.root
      end
      foreign_source.xpath("/foreign-source/detectors/detector[@name = '#{service_name}']")[0].remove
      fs_resource(new_resource.foreign_source_name).message foreign_source.to_s
    end
  end
end

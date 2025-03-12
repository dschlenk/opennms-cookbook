include Opennms::Cookbook::Provision::ForeignSourceHttpRequest
include Opennms::XmlHelper
include Opennms::Rbac

property :service_name, String, name_property: true
property :class_name, String
property :foreign_source_name, String, identity: true
property :parameters, Hash, callbacks: { 'should be a hash with key/value pairs that are both strings' => ->(p) { !p.any? { |k, v| !k.is_a?(String) || !v.is_a?(String) } } }

load_current_value do |new_resource|
  foreign_source = REXML::Document.new(fs_resource(new_resource.foreign_source_name).message) unless fs_resource(new_resource.foreign_source_name).nil?
  foreign_source = REXML::Document.new(Opennms::Cookbook::Provision::ForeignSource.new(new_resource.foreign_source_name, "#{baseurl}/foreignSources/#{new_resource.foreign_source_name}").message) if foreign_source.nil?
  current_value_does_not_exist! if foreign_source.nil?
  sd_el = foreign_source.elements["/foreign-source/detectors/detector[@name = '#{new_resource.service_name}']"]
  current_value_does_not_exist! if sd_el.nil?
  fs_detector = foreign_source.elements["/foreign-source/detectors/detector[@name = '#{new_resource.service_name}']"]
  current_value_does_not_exist! if fs_detector.nil?
  fs_params = {}
  class_name fs_detector.attributes['class'] unless fs_detector.attributes['class'].nil?
  fs_detector.each_element('parameter') do |parameter|
    fs_params[parameter.attributes['key']] = parameter.attributes['value']
  end
  parameters fs_params
end

action_class do
  include Opennms::Cookbook::Provision::ForeignSourceHttpRequest
  include Opennms::XmlHelper
  include Opennms::Rbac
end

action :create do
  converge_if_changed do
    fs_resource_init(new_resource.foreign_source_name)
    service_name = new_resource.service_name
    foreign_source = REXML::Document.new(fs_resource(new_resource.foreign_source_name).message).root
    raise Chef::Exceptions::ValidationFailed "No foreign source definition named #{new_resource.foreign_source_name} found. Create it with an opennms_foreign_source[#{new_resource.foreign_source_name}] resource." if foreign_source.nil?
    detector = foreign_source.elements["/foreign-source/detectors/detector[@name = '#{service_name}']"]
    if detector.nil?
      detectors_el = foreign_source.elements['/foreign-source/detectors']
      # Create detector element and add the name attributes and class attribute
      detector_el = REXML::Element.new('detector')
      unless service_name.nil?
        detector_el.add_attribute('name', service_name)
      end
      unless new_resource.class_name.nil?
        detector_el.add_attribute('class', new_resource.class_name)
      end
      unless new_resource.parameters.nil?
        new_resource.parameters.each do |key, value|
          detector_el.add_element 'parameter', 'key' => key, 'value' => value
        end
      end
      # then add the element to foreign_source.elements["/detectors"]
      if detectors_el.nil?
        foreign_source.add_element(REXML::Element.new('detectors', detector_el))
      else
        detectors_el.add_element detector_el
      end
    else # one already exists, so you need to maybe update class
      unless new_resource.class_name.nil?
        detector.attributes['class'] = new_resource.class_name
      end
      # delete all parameters
      detector.elements.delete_all 'parameter'
      # Add all parameter back with new values
      new_resource.parameters.each do |key, value|
        detector.add_element 'parameter', 'key' => key, 'value' => value
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
    foreign_source = REXML::Document.new(fs_resource(new_resource.foreign_source_name).message).root
    detector = foreign_source.elements["detectors/detector[@name = '#{service_name}']"] unless foreign_source.nil?
    if detector.nil?
      run_action(:create)
    end
  end
end

action :delete do
  foreign_source = REXML::Document.new(Opennms::Cookbook::Provision::ForeignSource.new(new_resource.foreign_source_name, "#{baseurl}/foreignSources/#{new_resource.foreign_source_name}").message) if foreign_source.nil?
  service_name = new_resource.service_name
  detector = foreign_source.elements["/foreign-source/detectors/detector[@name = '#{service_name}']"] unless foreign_source.nil?
  unless detector.nil?
    converge_by("Removing service detector #{service_name} from foreign source #{new_resource.foreign_source_name}") do
      fs_resource_init(new_resource.foreign_source_name)
      foreign_source = REXML::Document.new(fs_resource(new_resource.foreign_source_name).message).root
      foreign_source.elements.delete("/foreign-source/detectors/detector[@name = '#{service_name}']")
      fs_resource(new_resource.foreign_source_name).message foreign_source.to_s
    end
  end
end

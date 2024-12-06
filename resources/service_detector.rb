include Opennms::Cookbook::Provision::ForeignSourceHttpRequest
include Opennms::XmlHelper
include Opennms::Rbac

property :service_name, String, name_property: true
property :port, Integer
property :retry_count, Integer
property :timeout, Integer
property :class_name, String
property :foreign_source_name, String, identity: true
property :parameters, Hash, callbacks: { 'should be a hash with key/value pairs that are both strings' => lambda { |p| !p.any? { |k, v| !k.is_a?(String) || !v.is_a?(String) }
}, }

load_current_value do |new_resource|
  foreign_source = REXML::Document.new(fs_resource(new_resource.foreign_source_name).message) unless fs_resource(new_resource.foreign_source_name).nil?
  foreign_source = REXML::Document.new(Opennms::Cookbook::Provision::ForeignSource.new(new_resource.foreign_source_name, "#{baseurl}/foreignSources/#{new_resource.foreign_source_name}").message) if foreign_source.nil?
  current_value_does_not_exist! if foreign_source.nil? || foreign_source.elements["/detectors/detector[@name = '#{new_resource.service_name}']"].nil?
  fs_detector = foreign_source.elements["/detectors/detector[@name = '#{new_resource.service_name}']"]
  current_value_does_not_exist! if fs_detector.nil?
  fs_detector_param = {}
  fs_params = {}
  class_name fs_detector.attributes['class']
  fs_detector.each_element('parameter') do |parameter|
    fs_params[parameter.attributes['key']] = parameter.attributes['value']
  end
  fs_params.each do |k, v|
    case k
    when 'timeout', 'port', 'retry_count'
      sym = k.to_sym
      if new_resource.send(sym).is_a?(Integer)
        value = begin
          Integer(v)
        rescue
          v
        end
        send(sym, value)
      else fs_detector_param[k] = v
      end
    else fs_detector_param[k] = v
    end
  end
  parameters fs_detector_param
end

action_class do
  include Opennms::Cookbook::Provision::ForeignSourceHttpRequest
  include Opennms::XmlHelper
  include Opennms::Rbac
end

action :create do
  converge_if_changed do
    fs_resource_init(new_resource.foreign_source_name)
    service_name = new_resource.service_name || new_resource.name
    foreign_source = REXML::Document.new(fs_resource(new_resource.foreign_source_name).message).root
    detector = foreign_source.elements["/detectors/detector[@name = '#{service_name}']"]
    # create a REXML::Element with a name attribute and a class attribute, then add parameter children for each of new_resource.parameters + timeout, retry_count, port
    # then add the element to foreign_source.elements["/detectors"]
    if detector.nil?
      detector_el = REXML::Element.new('detector' 'name' => service_name, 'class' => new_resource.class_name)
      new_resource.parameters.each do |key, value|
        detector_el.add_element 'parameter', 'key' => key, 'value' => value
      end
      foreign_source.add_element 'detectors' => detector_el
    else # one already exists, so you need to maybe update class
      # and then replace all the parameters that currently exist with new_resource.parameters + timeout, retry_count, port
      detector.attributes['class'] = new_resource.class_name

      detector.each_element('parameter') do |parameter|
        detector[parameter.attributes['key']] = new_resource.parameters.attributes['key']
        detector[parameter.attributes['value']] = new_resource.parameters.attributes['value']
      end
      foreign_source.add_element 'detectors' => detector
    end
    # update fs_resource.message with foreign_source.to_s
    fs_resource(new_resource.name).message foreign_source.to_s
  end
end

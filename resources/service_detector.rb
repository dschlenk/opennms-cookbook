include Opennms::Cookbook::Provision::ForeignSourceHttpRequest
include Opennms::XmlHelper
include Opennms::Rbac

property :service_name, String, name_property: true
property :port, Integer
property :retry_count, Integer
property :timeout, Integer
property :class_name, String
property :foreign_source_name, String, identity: true
property :parameters, Hash, callbacks: { 'should be a hash with key/value pairs that are both strings' => lambda { |p| !p.any? { |k, v| !k.is_a?(String) || !v.is_a?(String) } }, }

load_current_value do |new_resource|
  foreign_source = REXML::Document.new(fs_resource(new_resource.foreign_source_name).message) unless fs_resource(new_resource.foreign_source_name).nil?
  foreign_source = REXML::Document.new(Opennms::Cookbook::Provision::ForeignSource.new(new_resource.foreign_source_name, "#{baseurl}/foreignSources/#{new_resource.foreign_source_name}").message) if foreign_source.nil?
  current_value_does_not_exist! if foreign_source.nil? || foreign_source.elements["detectors/detector[@name = '#{new_resource.service_name}']"].nil?
  fs_detector = foreign_source.elements["detectors/detector[@name = '#{new_resource.service_name}']"]
  current_value_does_not_exist! if fs_detector.nil?
  fs_detector_param = {}
  fs_params = {}
  class_name fs_detector.attributes['class'] if fs_detector.attributes['class'].nil?
  unless fs_detector.nil?
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
    service_name = new_resource.service_name
    foreign_source = REXML::Document.new(fs_resource(new_resource.foreign_source_name).message).root
    detector = foreign_source.elements["detectors/detector[@name = '#{service_name}']"] unless foreign_source.nil?
    detectors_el = foreign_source.elements["detectors"] unless foreign_source.nil?
    # create a REXML::Element with a name attribute and a class attribute,
    if detector.nil?
      #Create detector element and add the attributes
      detector_el = REXML::Element.new('detector')
      detector_el.add_attribute('name', service_name)
      detector_el.add_attribute('class', new_resource.class_name)

      # then add parameter children for each of new_resource.parameters + timeout, retry_count, port
      unless new_resource.timeout.nil?
        detector_el.add_element 'parameter', 'key' => 'timeout', 'value' => new_resource.timeout
      end
      unless new_resource.port.nil?
        detector_el.add_element 'parameter', 'key' => 'port', 'value' => new_resource.port
      end
      unless new_resource.retry_count.nil?
        detector_el.add_element 'parameter', 'key' => 'retries', 'value' => new_resource.retry_count
      end

      unless new_resource.parameters.nil?
        new_resource.parameters.each do |key, value|
          next if %w(port retries timeout).include?(key)
          detector_el.add_element 'parameter', 'key' => key, 'value' => value
        end
      end
      # then add the element to foreign_source.elements["/detectors"]
      if detectors_el.nil?
        foreign_source.add_element(REXML::Element.new('detectors', detector_el))
      else detectors_el.add_element detector_el
      end
    else # one already exists, so you need to maybe update class
      unless new_resource.class_name.nil?
        detector.attributes['class'] = new_resource.class_name
      end

      if new_resource.parameters.is_a?(Hash) && !new_resource.parameters.empty?
        # clear out all parameters
        detector.elements.delete_all 'parameter'
        # add them back with new values
        new_resource.parameters.each do |key, value|
          detector.add_element 'parameter', 'key' => key, 'value' => value
        end
      end

      # and then replace all the parameters that currently exist with new_resource.parameters + timeout, retry_count, port
      unless new_resource.timeout.nil?
        timeout_el = detector.elements["parameter[@key='timeout']"]
        if timeout_el.nil?
          detector.add_element 'parameter', 'key' => 'timeout', 'value' => new_resource.timeout
        else
          timeout_el.attributes['value'] = new_resource.timeout
        end
      end
      unless new_resource.port.nil?
        port_el = detector.elements["parameter[@key='port']"]
        if port_el.nil?
          detector.add_element 'parameter', 'key' => 'port', 'value' => new_resource.port
        else
          port_el.attributes['value'] = new_resource.port
        end
      end
      unless new_resource.retry_count.nil?
        retries_el = detector.elements["parameter[@key='retries']"]
        if retries_el.nil?
          detector.add_element 'parameter', 'key' => 'port', 'value' => new_resource.retry_count
        else
          retries_el.attributes['value'] = new_resource.retry_count
        end
      end
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
  fs_resource_init(new_resource.foreign_source_name)
  service_name = new_resource.service_name
  foreign_source = REXML::Document.new(fs_resource(new_resource.foreign_source_name).message).root
  detector = foreign_source.elements["detectors/detector[@name = '#{service_name}']"] unless foreign_source.nil?
  if !detector.nil?
    converge_by("Removing service detector #{service_name} from foreign source #{new_resource.foreign_source_name}") do
      foreign_source.delete_element(detector) unless detector.nil?
    end
  end
  # update fs_resource.message with foreign_source.to_s
  fs_resource(new_resource.foreign_source_name).message foreign_source.to_s
end

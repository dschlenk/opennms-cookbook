include Opennms::Cookbook::Provision::ForeignSourceHttpRequest
include Opennms::XmlHelper
include Opennms::Rbac

property :policy_name, String, name_property: true
property :class_name, String, required: true
property :foreign_source_name, String, identity: true
property :parameters, Hash, callbacks: { 'should be a hash with key/value pairs that are both strings' => lambda { |p| !p.any? { |k, v| !k.is_a?(String) || !v.is_a?(String) } }, }

load_current_value do |new_resource|
  foreign_source = REXML::Document.new(fs_resource(new_resource.foreign_source_name).message) unless fs_resource(new_resource.foreign_source_name).nil?
  foreign_source = REXML::Document.new(Opennms::Cookbook::Provision::ForeignSource.new(new_resource.foreign_source_name, "#{baseurl}/foreignSources/#{new_resource.foreign_source_name}").message) if foreign_source.nil?
  current_value_does_not_exist! if foreign_source.nil? || foreign_source.elements["policies/policy[@name = '#{new_resource.policy_name}']"].nil?
  fs_policy = foreign_source.elements["policies/policy[@name = '#{new_resource.policy_name}']"]
  current_value_does_not_exist! if fs_policy.nil?
  fs_policy_param = {}
  fs_params = {}
  class_name fs_policy.attributes['class'] if fs_policy.attributes['class'].nil?
  unless fs_policy.nil?
    fs_policy.each_element('parameter') do |parameter|
      fs_params[parameter.attributes['key']] = parameter.attributes['value']
    end
  end
  parameters fs_policy_param
end

action_class do
  include Opennms::Cookbook::Provision::ForeignSourceHttpRequest
  include Opennms::XmlHelper
  include Opennms::Rbac
end

action :create do
  converge_if_changed do
    fs_resource_init(new_resource.foreign_source_name)
    policy_name = new_resource.policy_name
    foreign_source = REXML::Document.new(fs_resource(new_resource.foreign_source_name).message).root
    policy = foreign_source.elements["policies/policy[@name = '#{policy_name}']"] unless foreign_source.nil?
    policies_el = foreign_source.elements["policies"] unless foreign_source.nil?
    if policy.nil?
      # Create detector element and add the name attributes and class attribute
      policy_el = REXML::Element.new('policy')
      unless policy_name.nil?
        policy_el.add_attribute('name', policy_name)
      end
      unless new_resource.class_name.nil?
        policy_el.add_attribute('class', new_resource.class_name)
      end
      unless new_resource.parameters.nil?
        new_resource.parameters.each do |key, value|
          policy_el.add_element 'parameter', 'key' => key, 'value' => value
        end
      end
      # then add the element to foreign_source.elements["/detectors"]
      if policies_el.nil?
        foreign_source.add_element(REXML::Element.new('policies', policy_el))
      else policies_el.add_element policy_el
      end
    else # one already exists, so you need to maybe update class
      unless new_resource.class_name.nil?
        policy.attributes['class'] = new_resource.class_name
      end
      # delete all parameters
      policy.elements.delete_all 'parameter'
      # Add all parameter back with new values
      if new_resource.parameters.is_a?(Hash) && !new_resource.parameters.empty?
        new_resource.parameters.each do |key, value|
          policy.add_element 'parameter', 'key' => key, 'value' => value
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
    policy_name = new_resource.policy_name
    foreign_source = REXML::Document.new(fs_resource(new_resource.foreign_source_name).message).root
    policy = foreign_source.elements["policies/policy[@name = '#{policy_name}']"] unless foreign_source.nil?
    if policy.nil?
      run_action(:create)
    end
  end
end

action :delete do
  fs_resource_init(new_resource.foreign_source_name)
  policy_name = new_resource.policy_name
  foreign_source = REXML::Document.new(fs_resource(new_resource.foreign_source_name).message).root
  policy = foreign_source.elements["policies/policy[@name = '#{policy_name}']"] unless foreign_source.nil?
  if !policy.nil?
    converge_by("Removing service detector #{policy_name} from foreign source #{new_resource.foreign_source_name}") do
      foreign_source.delete_element(policy) unless policy.nil?
    end
  end
  # update fs_resource.message with foreign_source.to_s
  fs_resource(new_resource.foreign_source_name).message foreign_source.to_s
end

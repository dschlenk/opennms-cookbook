include Opennms::XmlHelper
include Opennms::Cookbook::Discovery::ConfigurationTemplate
property :location, String, identity: true
property :range_begin, String, required: true, identity: true
property :range_end,   String, required: true, identity: true
property :range_type,  String, equal_to: %w(include exclude), default: 'include', identity: true
property :retry_count, Integer
property :timeout,     Integer
property :foreign_source, String

load_current_value do |new_resource|
  config = disco_resource.variables[:config] unless disco_resource.nil?
  if config.nil?
    ro_disco_resource_init
    config = ro_disco_resource.variables[:config]
  end
  range = if new_resource.range_type.eql?('include')
            config.include_range(begin_ip: new_resource.range_begin, end_ip: new_resource.range_end, location: new_resource.location)
          else
            config.exclude_range(begin_ip: new_resource.range_begin, end_ip: new_resource.range_end, location: new_resource.location)
          end
  current_value_does_not_exist! if range.nil?
  if new_resource.range_type.eql?('include')
    %i(retry_count timeout foreign_source).each do |p|
      send(p, range[p])
    end
  else
    # ignored for exclude, so just mirror new_resource
    %i(retry_count timeout foreign_source).each do |p|
      send(p, new_resource.send(p))
    end
  end
end

action_class do
  include Opennms::XmlHelper
  include Opennms::Cookbook::Discovery::ConfigurationTemplate
end

action :create do
  converge_if_changed do
    disco_resource_init
    config = disco_resource.variables[:config]
    range = if new_resource.range_type.eql?('include')
              config.include_range(begin_ip: new_resource.range_begin, end_ip: new_resource.range_end, location: new_resource.location)
            else
              config.exclude_range(begin_ip: new_resource.range_begin, end_ip: new_resource.range_end, location: new_resource.location)
            end
    if range.nil?
      rp = %i(retry_count timeout location foreign_source).map { |p| [p, new_resource.send(p)] }.to_h.compact
      rp[:begin_ip] = new_resource.range_begin
      rp[:end_ip] = new_resource.range_end
      case new_resource.range_type
      when 'include'
        config.add_include_range(**rp)
      when 'exclude'
        config.add_exclude_range(**rp)
      end
    else
      run_action(:update)
    end
  end
end

action :create_if_missing do
  disco_resource_init
  config = disco_resource.variables[:config]
  range = if new_resource.range_type.eql?('include')
            config.include_range(begin_ip: new_resource.range_begin, end_ip: new_resource.range_end, location: new_resource.location)
          else
            config.exclude_range(begin_ip: new_resource.range_begin, end_ip: new_resource.range_end, location: new_resource.location)
          end
  run_action(:create) if range.nil?
end

action :update do
  disco_resource_init
  config = disco_resource.variables[:config]
  range = if new_resource.range_type.eql?('include')
            config.include_range(begin_ip: new_resource.range_begin, end_ip: new_resource.range_end, location: new_resource.location)
          else
            config.exclude_range(begin_ip: new_resource.range_begin, end_ip: new_resource.range_end, location: new_resource.location)
          end
  raise Chef::Exceptions::ResourceNotFound, "No #{new_resource.range_type}-range element with starting IP address #{new_resource.range_begin} and ending IP address #{new_resource.range_end} at location #{new_resource.location} found in config file. Use action `:create` or `:create_if_missing` to add it." if range.nil?
  converge_if_changed do
    %i(retry_count timeout foreign_source).each do |p|
      range[p] = new_resource.send(p) unless new_resource.send(p).nil?
    end
  end unless new_resource.range_type.eql?('exclude') # exclude ranges have no updateable properties
end

action :delete do
  disco_resource_init
  config = disco_resource.variables[:config]
  range = if new_resource.range_type.eql?('include')
            config.include_range(begin_ip: new_resource.range_begin, end_ip: new_resource.range_end, location: new_resource.location)
          else
            config.exclude_range(begin_ip: new_resource.range_begin, end_ip: new_resource.range_end, location: new_resource.location)
          end
  converge_by "Removing #{new_resource.range_type}-range element  with starting IP address #{new_resource.range_begin} and ending IP address #{new_resource.range_end}#{new_resource.location.nil? ? '' : " at location #{new_resource.location}"} from discovery config" do
    if new_resource.range_type.eql?('include')
      config.delete_include_range(begin_ip: new_resource.range_begin, end_ip: new_resource.range_end, location: new_resource.location)
    else
      config.delete_exclude_range(begin_ip: new_resource.range_begin, end_ip: new_resource.range_end, location: new_resource.location)
    end
  end unless range.nil?
end

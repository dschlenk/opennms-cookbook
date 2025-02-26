include Opennms::XmlHelper
include Opennms::Cookbook::Discovery::ConfigurationTemplate
property :url, String, name_property: true
property :location, String, identity: true
property :url_type, String, equal_to: %w(include exclude), default: 'include', identity: true
property :file_name, String
property :retry_count, Integer
property :timeout, Integer
property :foreign_source, String

load_current_value do |new_resource|
  config = disco_resource.variables[:config] unless disco_resource.nil?
  config = Opennms::Cookbook::Discovery::Configuration.read("#{onms_etc}/discovery-configuration.xml") if config.nil?
  url = if new_resource.url_type.eql?('include')
          config.include_url(url: new_resource.url, location: new_resource.location)
        else
          config.exclude_url(url: new_resource.url, location: new_resource.location)
        end
  current_value_does_not_exist! if url.nil?
  if new_resource.url_type.eql?('include')
    %i(retry_count timeout foreign_source).each do |p|
      send(p, url[p])
    end
  else
    # ignored for exclude, so just mirror new_resource
    %i(retry_count timeout foreign_source).each do |p|
      send(p, new_resource.send(p))
    end
  end
  # ignore file_name since the declared cookbook_file resource will handle changes when needed
  file_name new_resource.file_name
end

action_class do
  include Opennms::XmlHelper
  include Opennms::Cookbook::Discovery::ConfigurationTemplate
end

action :create do
  if new_resource.url =~ /^file:(.*$)/
    unless new_resource.file_name.nil?
      cookbook_file new_resource.file_name do
        path Regexp.last_match(1)
        owner node['opennms']['username']
        group node['opennms']['groupname']
        mode '0644'
      end
    end
  end
  converge_if_changed do
    disco_resource_init
    config = disco_resource.variables[:config]
    url = if new_resource.url_type.eql?('include')
            config.include_url(url: new_resource.url, location: new_resource.location)
          else
            config.exclude_url(url: new_resource.url, location: new_resource.location)
          end
    if url.nil?
      rp = %i(url retry_count timeout location foreign_source).map { |p| [p, new_resource.send(p)] }.to_h.compact
      case new_resource.url_type
      when 'include'
        config.add_include_url(**rp)
      when 'exclude'
        config.add_exclude_url(**rp)
      end
    else
      run_action(:update)
    end
  end
end

action :create_if_missing do
  disco_resource_init
  config = disco_resource.variables[:config]
  url = if new_resource.url_type.eql?('include')
          config.include_url(url: new_resource.url, location: new_resource.location)
        else
          config.exclude_url(url: new_resource.url, location: new_resource.location)
        end
  run_action(:create) if url.nil?
end

action :update do
  if new_resource.url =~ /^file:(.*$)/ && !new_resource.file_name.nil?
    cookbook_file new_resource.file_name do
      path Regexp.last_match(1)
      owner node['opennms']['username']
      group node['opennms']['groupname']
      mode '0644'
    end unless find_resource(:cookbook_file, new_resource.file_name).nil?
  end
  disco_resource_init
  config = disco_resource.variables[:config]
  url = if new_resource.url_type.eql?('include')
          config.include_url(url: new_resource.url, location: new_resource.location)
        else
          config.exclude_url(url: new_resource.url, location: new_resource.location)
        end
  raise Chef::Exceptions::ResourceNotFound, "No #{new_resource.url_type}-url element with URL #{new_resource.url} at location #{new_resource.location} found in config file. Use action `:create` or `:create_if_missing` to add it." if url.nil?
  converge_if_changed do
    %i(retry_count timeout foreign_source).each do |p|
      url[p] = new_resource.send(p) unless new_resource.send(p).nil?
    end
  end unless new_resource.url_type.eql?('exclude') # exclude urls have no updateable properties
end

action :delete do
  disco_resource_init
  config = disco_resource.variables[:config]
  url = if new_resource.url_type.eql?('include')
          config.include_url(url: new_resource.url, location: new_resource.location)
        else
          config.exclude_url(url: new_resource.url, location: new_resource.location)
        end
  converge_by "Removing #{new_resource.url_type}-url element with URL #{new_resource.url}#{new_resource.location.nil? ? '' : " at location #{new_resource.location}"} from discovery config" do
    if new_resource.url_type.eql?('include')
      config.delete_include_url(url: new_resource.url, location: new_resource.location)
    else
      config.delete_exclude_url(url: new_resource.url, location: new_resource.location)
    end
  end unless url.nil?
end

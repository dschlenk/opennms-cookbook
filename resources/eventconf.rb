unified_mode true

property :event_file, String, name_property: true, identity: true
property :source_type, String, equal_to: %w(cookbook_file template remote_file), default: 'cookbook_file', desired_state: false
property :source, String
property :source_properties, Hash, desired_state: false
property :position, String, equal_to: %w(override top bottom), default: 'bottom', desired_state: false
property :variables, Hash

action_class do
  include Opennms::Cookbook::ConfigHelpers::Event::EventConfTemplate
end

load_current_value do |new_resource|
  current_value_does_not_exist! unless ::File.exist?("#{node['opennms']['conf']['home']}/etc/events/#{new_resource.event_file}")
  eventconf = Opennms::Cookbook::ConfigHelpers::Event::EventConf.read("#{node['opennms']['conf']['home']}/etc/eventconf.xml", node)
  current_value_does_not_exist! if eventconf.event_files[new_resource.name].nil?
  position eventconf.event_files[new_resource.name][:position]
end

action :create do
  # always declare the resource that manages the file
  case new_resource.source_type
  when 'cookbook_file'
    cookbook_file "#{node['opennms']['conf']['home']}/etc/events/#{new_resource.event_file}" do
      source new_resource.source || new_resource.name
      owner node['opennms']['username']
      group node['opennms']['groupname']
      mode 0664
      new_resource.source_properties.each do |k,v|
        send(k, v)
      end unless new_resource.source_properties.nil?
    end
  when 'template'
    template "#{node['opennms']['conf']['home']}/etc/events/#{new_resource.event_file}" do
      source new_resource.source || "#{new_resource.name}.erb"
      owner node['opennms']['username']
      group node['opennms']['groupname']
      mode 0664
      variables new_resource.variables
      new_resource.source_properties.each do |k,v|
        send(k, v)
      end unless new_resource.source_properties.nil?
    end
  when 'remote_file'
    remote_file "#{node['opennms']['conf']['home']}/etc/events/#{new_resource.event_file}" do
      source new_resource.source || new_resource.name
      owner node['opennms']['username']
      group node['opennms']['groupname']
      mode 0664
      new_resource.source_properties.each do |k,v|
        send(k, v)
      end unless new_resource.source_properties.nil?
    end
  end
  # maybe update eventconf.xml
  converge_if_changed do
    eventconf_resource_init
    eventconf_resource.variables[:eventconf].event_files[new_resource.event_file] = { position: new_resource.position }
  end
end

action :delete do
  file "#{node['opennms']['conf']['home']}/etc/events/#{new_resource.event_file}" do
    action :delete
  end
  eventconf_resource_init
  eventconf_resource.variables[:eventconf].event_files.delete(new_resource.event_file)
end

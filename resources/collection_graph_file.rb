
include Opennms::XmlHelper
property :file, String, name_property: true, identity: true
property :source, String, default: 'cookbook_file', desired_state: false

load_current_value do |new_resource|
  current_value_does_not_exist! unless ::File.exist?("#{onms_etc}/snmp-graph.properties.d/#{new_resource.file}")
end

action_class do
  include Opennms::XmlHelper
end

action :create do
  with_run_context(:root) do
    declare_resource(:file, "#{onms_etc}/snmp-graph.properties") do
      action :nothing
    end
  end
  if new_resource.source.eql?('cookbook_file') # only do this if source
    cookbook_file new_resource.file do
      path "#{onms_etc}/snmp-graph.properties.d/#{new_resource.file}"
      owner node['opennms']['username']
      group node['opennms']['groupname']
      mode '0644'
      notifies :touch, "file[#{onms_etc}/snmp-graph.properties]", :immediately
    end
  else
    remote_file new_resource.file do
      action :create
      path "#{onms_etc}/snmp-graph.properties.d/#{new_resource.file}"
      source new_resource.source
      owner node['opennms']['username']
      group node['opennms']['groupname']
      mode '0644'
      notifies :touch, "file[#{onms_etc}/snmp-graph.properties]", :immediately
    end
  end
end
action :create_if_missing do
  run_action(:create) unless ::File.exist?("#{onms_etc}/snmp-graph.properties.d/#{new_resource.file}")
end
action :delete do
  if ::File.exist?("#{onms_etc}/snmp-graph.properties.d/#{new_resource.file}")
    with_run_context(:root) do
      declare_resource(:file, "#{onms_etc}/snmp-graph.properties") do
        action :nothing
      end
    end
    file "#{onms_etc}/snmp-graph.properties.d/#{new_resource.file}" do
      action :delete
      notifies :touch, "file[#{onms_etc}/snmp-graph.properties]", :immediately
    end
  end
end

 

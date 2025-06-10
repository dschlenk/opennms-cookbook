unified_mode true
 
property :rule_name, String, name_property: true, identity: true
property :engine_source, String
property :engine_source_type, String,
  default: 'template',
  equal_to: %w(template remote_file cookbook_file)
property :engine_source_variables, Hash, default: nil
property :engine_source_properties, Hash, default: nil
 
property :drl_source, [String, Array], default: nil
property :drl_source_type, String,
  default: 'cookbook_file',
  equal_to: %w(template remote_file cookbook_file)
property :drl_source_variables, Hash, default: nil
property :drl_source_properties, Hash, default: nil
 
property :notify, [true, false], default: false
property :notify_type, String,
  default: 'soft',
  equal_to: %w(soft hard)
 
action_class do
  def base_path
    ::File.join(node['opennms']['conf']['home'], 'etc', 'drools-engine.d', new_resource.rule_name)
  end
 
  def correlation_exists?
    ::File.directory?(base_path) && ::File.exist?(::File.join(base_path, 'drools-engine.xml'))
  end
 
  def engine_names
    require 'chef/util/xpath_helper'
    xml_path = ::File.join(base_path, 'drools-engine.xml')
    return [] unless ::File.exist?(xml_path)
 
    xml_content = ::File.read(xml_path)
    doc = Chef::Util::XPathHelper.new(xml_content)
    doc.xpath('/engine-configuration/rule-set/@name').map(&:value)
  rescue StandardError => e
    Chef::Log.warn("Failed to parse drools-engine.xml for notify engines: #{e}")
    []
  end
end
 
action :create do
  unless correlation_exists?
    directory base_path do
      owner node['opennms']['username']
      group node['opennms']['groupname']
      mode '0755'
      recursive true
      action :create
    end
 
    send(new_resource.engine_source_type, ::File.join(base_path, 'drools-engine.xml')) do
      source new_resource.engine_source
      owner node['opennms']['username']
      group node['opennms']['groupname']
      mode '0644'
      if new_resource.engine_source_type == 'template' && new_resource.engine_source_variables
        variables new_resource.engine_source_variables
      end
      if new_resource.engine_source_properties
        new_resource.engine_source_properties.each { |k, v| send(k, v) }
      end
      action :create
    end
 
    Array(new_resource.drl_source).each do |drl_file|
      filename =
        case new_resource.drl_source_type
        when 'template'
          drl_file.sub(/\.erb$/, '')
        when 'remote_file'
          ::File.basename(drl_file)
        else
          drl_file
        end
 
      send(new_resource.drl_source_type, ::File.join(base_path, filename)) do
        source drl_file
        owner node['opennms']['username']
        group node['opennms']['groupname']
        mode '0644'
        if new_resource.drl_source_type == 'template' && new_resource.drl_source_variables
          variables new_resource.drl_source_variables
        end
        if new_resource.drl_source_properties
          new_resource.drl_source_properties.each { |k, v| send(k, v) }
        end
        action :create
      end
    end
  end
 
  if new_resource.notify && correlation_exists?
    case new_resource.notify_type
    when 'soft'
      engine_names.each do |engine_name|
        send_event_res = "reload_#{engine_name}".to_sym
        opennms_send_event send_event_res do
          uei 'uei.opennms.org/internal/reloadDaemonConfig'
          parameters "DroolsCorrelationEngine-#{engine_name}.xml"
          action :nothing
        end
 
        resources("directory[#{base_path}]").each do |res|
          res.notifies :run, "opennms_send_event[#{send_event_res}]"
        end
      end
    when 'hard'
      execute "reload_drools_correlation_#{new_resource.rule_name}" do
        command %Q(
          mv '#{base_path}' #{Chef::Config[:file_cache_path]}/ &&
          #{node['opennms']['conf']['home']}/bin/send-event.pl uei.opennms.org/internal/reloadDaemonConfig -p 'daemonName DroolsCorrelationEngine' &&
          sleep 10 &&
          mv '#{Chef::Config[:file_cache_path]}/#{new_resource.rule_name}' #{base_path} &&
          #{node['opennms']['conf']['home']}/bin/send-event.pl uei.opennms.org/internal/reloadDaemonConfig -p 'daemonName DroolsCorrelationEngine'
        )
        action :nothing
      end
 
      resources("directory[#{base_path}]").each do |res|
        res.notifies :run, "execute[reload_drools_correlation_#{new_resource.rule_name}]"
      end
    end
  end
end
 
action :create_if_missing do
  run_action(:create) unless correlation_exists?
end
 
action :delete do
  if correlation_exists?
    directory base_path do
      recursive true
      action :delete
    end
  end
end

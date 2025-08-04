unified_mode true

property :rule_name, String, name_property: true, identity: true
property :engine_source, String
property :engine_source_type, String, default: 'template', equal_to: %w(template remote_file cookbook_file)
property :engine_source_variables, Hash
property :engine_source_properties, Hash

property :drl_source, [String, Array]
property :drl_source_type, String, default: 'cookbook_file', equal_to: %w(template remote_file cookbook_file)
property :drl_source_variables, Hash
property :drl_source_properties, Hash

property :notify, [true, false], default: true, desired_state: false
property :notify_type, String, default: 'soft', equal_to: %w(soft hard), desired_state: false

action_class do
  include Opennms::Cookbook::Correlation::DroolsRuleTemplate
end

action :create do
  raise Chef::Exceptions::ValidationFailed, 'engine_source is a required property for action :create' if new_resource.engine_source.nil?
  raise Chef::Exceptions::ValidationFailed, 'Correlator service is not enabled. Set `node[\'opennms\'][\'services\'][\'correlator\'] to `true` to enable.' unless node['opennms']['services']['correlator']
  dexml = ::File.join(base_path(new_resource.rule_name), 'drools-engine.xml')
  enames = engine_names(new_resource.rule_name)
  with_run_context(:root) do
    find_resource(:opennms_send_event, 'restart drools correlation engine') do
      parameters ['daemonName DroolsCorrelationEngine']
      action :nothing
    end

    find_resource(:execute, "hard restart drools correlation engine #{new_resource.rule_name}") do
      command "mv '#{node['opennms']['conf']['home']}/etc/drools-engine.d/#{new_resource.rule_name}' #{Chef::Config[:file_cache_path]}/ && #{node['opennms']['conf']['home']}/bin/send-event.pl uei.opennms.org/internal/reloadDaemonConfig -p 'daemonName DroolsCorrelationEngine' && sleep 10 && mv '#{Chef::Config[:file_cache_path]}/#{new_resource.rule_name}' #{node['opennms']['conf']['home']}/etc/drools-engine.d/ && #{node['opennms']['conf']['home']}/bin/send-event.pl uei.opennms.org/internal/reloadDaemonConfig -p 'daemonName DroolsCorrelationEngine'"
      action :nothing
    end

    enames.each do |ename|
      find_resource(:opennms_send_event, "restart DroolsCorrelationEngine-#{ename}") do
        parameters ["daemonName DroolsCorrelationEngine-#{ename}"]
        action :nothing
      end
    end
  end

  declare_resource(:directory, base_path(new_resource.rule_name)) do
    owner node['opennms']['username']
    group node['opennms']['groupname']
    mode '0755'
    recursive true
    notifies :run, 'opennms_send_event[restart drools correlation engine]'
  end

  find_resource(new_resource.engine_source_type.to_sym, dexml) do
    source new_resource.engine_source
    owner node['opennms']['username']
    group node['opennms']['groupname']
    mode '0644'
    variables new_resource.engine_source_variables if new_resource.engine_source_type == 'template' && new_resource.engine_source_variables
    new_resource.engine_source_properties&.each { |k, v| send(k, v) } unless new_resource.engine_source_properties.nil?
    enames.each do |ename|
      notifies :run, "opennms_send_event[restart DroolsCorrelationEngine-#{ename}]"
    end if new_resource.notify && new_resource.notify_type.eql?('soft') && !::File.exist?(dexml) # suppress on initial :create since the notify on the directory resource is enough
    notifies :run, "execute[hard restart drools correlation engine #{new_resource.rule_name}]" if new_resource.notify && new_resource.notify_type.eql?('hard') && !::File.exist?(dexml)
  end

  Array(new_resource.drl_source).each do |drl_file|
    filename = resolve_drl_filename(drl_file, new_resource.drl_source_type)
    find_resource(new_resource.drl_source_type.to_sym, ::File.join(base_path(new_resource.rule_name), filename)) do
      source drl_file
      owner node['opennms']['username']
      group node['opennms']['groupname']
      mode '00644'
      variables new_resource.drl_source_variables if new_resource.drl_source_type == 'template' && new_resource.drl_source_variables
      new_resource.drl_source_properties&.each { |k, v| send(k, v) } unless new_resource.drl_source_properties.nil?
      enames.each do |ename|
        notifies :run, "opennms_send_event[restart DroolsCorrelationEngine-#{ename}]"
      end if new_resource.notify && new_resource.notify_type.eql?('soft') && !::File.exist?(::File.join(base_path(new_resource.rule_name), filename))
      notifies :run, "execute[hard restart drools correlation engine #{new_resource.rule_name}]" if new_resource.notify && new_resource.notify_type.eql?('hard') && !::File.exist?(::File.join(base_path(new_resource.rule_name), filename))
    end
  end
end

action :create_if_missing do
  run_action(:create) unless correlation_exists?(new_resource.rule_name)
end

action :delete do
  with_run_context(:root) do
    find_resource(:opennms_send_event, 'restart drools correlation engine') do
      parameters ['daemonName DroolsCorrelationEngine']
      action :nothing
    end
  end
  directory base_path(new_resource.rule_name) do
    recursive true
    action :delete
    notifies :run, 'opennms_send_event[restart drools correlation engine]'
  end
end

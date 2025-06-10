unified_mode true

property :rule_name, String, name_property: true, identity: true
property :engine_source, String
property :engine_source_type, String, default: 'template', equal_to: %w(template remote_file cookbook_file)
property :engine_source_variables, Hash, default: nil
property :engine_source_properties, Hash, default: nil

property :drl_source, [String, Array], default: nil
property :drl_source_type, String, default: 'cookbook_file', equal_to: %w(template remote_file cookbook_file)
property :drl_source_variables, Hash, default: nil
property :drl_source_properties, Hash, default: nil

property :notify, [true, false], default: false
property :notify_type, String, default: 'soft', equal_to: %w(soft hard)

action_class do
  include Opennms::Cookbook::Correlation::DroolsRuleTemplate
end

action :create do
  directory base_path(new_resource.rule_name) do
    owner node['opennms']['username']
    group node['opennms']['groupname']
    mode '0755'
    recursive true
  end

  declare_resource(new_resource.engine_source_type.to_sym, :File.join(base_path(new_resource.rule_name), 'drools-engine.xml')) do
    source new_resource.engine_source
    owner node['opennms']['username']
    group node['opennms']['groupname']
    mode '0644'
    variables new_resource.engine_source_variables if new_resource.engine_source_type == 'template' && new_resource.engine_source_variables
    new_resource.engine_source_properties&.each { |k, v| send(k, v) }
  end

  Array(new_resource.drl_source).each do |drl_file|
    filename = resolve_drl_filename(drl_file, new_resource.drl_source_type)

    # TODO: change to declare_resource as above
    send(new_resource.drl_source_type, ::File.join(base_path(new_resource.rule_name), filename)) do
      source drl_file
      owner node['opennms']['username']
      group node['opennms']['groupname']
      mode '0644'
      variables new_resource.drl_source_variables if new_resource.drl_source_type == 'template' && new_resource.drl_source_variables
      new_resource.drl_source_properties&.each { |k, v| send(k, v) }
    end
  end
end

action :create_if_missing do
  run_action(:create) unless correlation_exists?(new_resource.rule_name)
end

action :delete do
  directory base_path(new_resource.rule_name) do
    recursive true
    action :delete
    # only_if { correlation_exists?(new_resource.rule_name) }
  end
end

# Adds/updates/deletes a graph in either the specified currently existing or
# new graph file in $ONMS_HOME/etc/snmp-graph.properties.d/
# or the default collection graph file, $ONMS_HOME/etc/snmp-graph.properties

include Opennms::XmlHelper
include Graph

property :short_name, String, name_property: true
property :file, String, identity: true # refers to the name of the file to add the graph def to
property :long_name, String, required: true
property :columns, Array, required: true, callbacks: {
  'should be an Array of Strings' => lambda { |p|
    !p.any? { |a| !a.is_a?(String) }
  },
}
property :type, String, required: true
property :command, String, required: true

action_class do
  include Opennms::XmlHelper
end

load_current_value do |new_resource|
  current_value_does_not_exist! unless ::File.exist?("#{onms_etc}/snmp-graph.properties.d/#{new_resource.file}")
  current_value_does_not_exist! unless check_file_for_graph("#{onms_etc}/snmp-graph.properties.d/#{new_resource.file}", new_resource.short_name)
end

# TODO: some day it would be nice to be able to handle updates and deletes
action :create do
  converge_if_changed do
    new_graph_file(new_resource.file, node) unless ::File.exist?("#{onms_etc}/snmp-graph.properties.d/#{new_resource.file}")
    add_collection_graph(new_resource, node)
    main_file = find_resource(:file, "#{node['opennms']['conf']['home']}/etc/snmp-graph.properties")
    if main_file.nil?
      with_run_contextd(:root) do
        declare_resource(:file, "#{node['opennms']['conf']['home']}/etc/snmp-graph.properties") do
          action :touch
        end
      end
    end
  end
end

action :create_if_missing do
  run_action(:create)
end

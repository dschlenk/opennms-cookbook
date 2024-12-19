include Opennms::XmlHelper

property :short_name, String, name_property: true
property :long_name, String
property :columns, Array, callbacks: {
  'should be an Array of Strings' => lambda { |p|
    p.is_a?(Array) && !p.any? { |a| !a.is_a?(String) }
  },
}
property :type, Array, default: ['responseTime', 'distributedStatus']
property :command, String

action_class do
  include Opennms::XmlHelper
end

load_current_value do |new_resource|
  current_value_does_not_exist! unless ::File.exist?("#{onms_etc}/response-graph.properties")
  current_value_does_not_exist! unless check_graph_in_file("#{onms_etc}/response-graph.properties", new_resource.short_name)
end

action :create do
  converge_if_changed do
    new_graph_file("#{onms_etc}/response-graph.properties") unless ::File.exist?("#{onms_etc}/response-graph.properties")
    add_graph_to_file(new_resource)
    Chef::Log.info("Created graph #{new_resource.short_name} in response-graph.properties")
  end
end

action :create_if_missing do
  run_action(:create)
end

action :delete do
  converge_if_changed do
    if check_graph_in_file(graph_file_path, new_resource.short_name)
      remove_graph_from_file(new_resource.short_name)
      Chef::Log.info("Deleted graph #{new_resource.short_name} from #{onms_etc}/response-graph.properties")
    else
      Chef::Log.warn("Graph #{new_resource.short_name} not found in #{onms_etc}/response-graph.properties. Skipping deletion.")
    end
  end
end

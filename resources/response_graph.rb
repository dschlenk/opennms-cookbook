include Opennms::XmlHelper
include Graph #fixed: missing module

property :short_name, String, name_property: true
property :long_name, String
property :columns, Array, callbacks: {
  'should be an Array of Strings' => lambda { |p|
    p.is_a?(Array) && !p.any? { |a| !a.is_a?(String) }
  },
}
property :type, Array, default: %w(responseTime distributedStatus)
property :command, String

action_class do
  include Opennms::XmlHelper
  include Graph #fixed: missing module
end

load_current_value do |new_resource|
  current_value_does_not_exist! unless ::File.exist?("#{onms_etc}/response-graph.properties")
  # fixed: method name not correct
  current_value_does_not_exist! unless check_file_for_graph("#{onms_etc}/response-graph.properties", new_resource.short_name)
end

action :create do
  converge_if_changed do
    new_graph_file("#{onms_etc}/response-graph.properties") unless ::File.exist?("#{onms_etc}/response-graph.properties")
    # fixed: method name not correct
    add_response_graph(new_resource)
    Chef::Log.info("Created graph #{new_resource.short_name} in response-graph.properties")
  end
end

action :create_if_missing do
  run_action(:create)
end

# TODO: implement the missing methods in libraries/graph.rb (noted below),
# write test code in test/fixtures/cookbooks/opennms_resource_tests/recipes/response_graph.rb that uses it
# and InSpec assertion code in test/integration/response_graph/controls/response_graph_spec.rb.
action :delete do
  # Typically you don't wrap :delete actions in converge_if_changed blocks. Instead, check to see if it exists and use a converge_by block if it does and do nothing if it doesn't. See resources/snmp_collection.rb for an example.
  converge_if_changed do
    # fixed: method name not correct
    if check_file_for_graph(graph_file_path, new_resource.short_name) # graph_file_path is not (yet?) a method in libraries/graph.rb
      remove_graph_from_file(new_resource.short_name) # remove_graph_from_file is not (yet) a method in libraries/graph.rb
      Chef::Log.info("Deleted graph #{new_resource.short_name} from #{onms_etc}/response-graph.properties")
    else
      # this is unnecessary - Chef will indicate that the resource was up to date already.
      Chef::Log.warn("Graph #{new_resource.short_name} not found in #{onms_etc}/response-graph.properties. Skipping deletion.")
    end
  end
end

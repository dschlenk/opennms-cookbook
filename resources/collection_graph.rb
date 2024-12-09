# Adds/updates/deletes a graph in either the specified currently existing or
# new graph file in $ONMS_HOME/etc/snmp-graph.properties.d/
# or the default collection graph file, $ONMS_HOME/etc/snmp-graph.properties

include Opennms::XmlHelper
include Opennms::Cookbook::Graph::CollectionGraphTemplate

property :short_name, String, name_property: true
property :file, String, identity: true # refers to the name of the file to add the graph def to
# required for new
property :long_name, String
# required for new
property :columns, Array, callbacks: {
  'should be an Array of Strings' => lambda { |p|
    !p.any? { |a| !a.is_a?(String) }
  }
}
# required for new
property :type, String
# required for new
property :command, String

action_class do
  include Opennms::XmlHelper
  include Opennms::Cookbook::Graph::CollectionGraphTemplate
end

load_current_value do |new_resource|
  current_value_does_not_exist! unless ::File.exist?("#{onms_etc}/snmp-graph.properties.d/#{new_resource.file}")
  gf = cgf_resource("#{onms_etc}/snmp-graph.properties.d/#{new_resource.file}").variables[:config] unless cgf_resource("#{onms_etc}/snmp-graph.properties.d/#{new_resource.file}").nil?
  gf = Opennms::Cookbook::Graph::CollectionGraphPropertiesFile.read("#{onms_etc}/snmp-graph.properties.d/#{new_resource.file}") if gf.nil?
  report = gf.reports[new_resource.short_name]
  current_value_does_not_exist! if report.nil?
  # this:
  %i(long_name columns type command).each do |p|
    send(p, report.send(p))
  end
  # is the same as this:
  #long_name report.long_name
  #columns report.columns
  #type report.type
  #command report.command
end

action :create do
end
action :create_if_missing do
end
action :update do
end
action :delete do
end

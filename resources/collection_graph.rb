# Adds/updates/deletes a graph in either the specified currently existing or
# new graph file in $ONMS_HOME/etc/snmp-graph.properties.d/
# or the default collection graph file, $ONMS_HOME/etc/snmp-graph.properties

# TODO: Pivot to light refactor using existing library
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
  },
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
  report = gf.report(short_name: new_resource.short_name)
  current_value_does_not_exist! if report.nil?
  %i(long_name columns type command).each do |p|
    send(p, report.send(p))
  end
end

action :create do
  converge_if_changed do
    cgf_resource_init("#{onms_etc}/snmp-graph.properties.d/#{new_resource.file}")
    gf = cgf_resource("#{onms_etc}/snmp-graph.properties.d/#{new_resource.file}").variables[:config]
    report = gf.report(short_name: new_resource.short_name)
    if report.nil?
      %i(long_name columns type command).each do |p|
        raise Chef::Exceptions::ValidationFailed, "Property #{p} must be defined when creating a new collection graph." if new_resource.send(p).nil?
      end
      # make a new report in the file
      gf.add_report(short_name: new_resource.short_name, long_name: new_resource.long_name, columns: new_resource.columns, type: new_resource.type, command: new_resource.command)
    else
      # update the existing report
      run_action(:update)
    end
  end
end

action :create_if_missing do
  cgf_resource_init("#{onms_etc}/snmp-graph.properties.d/#{new_resource.file}")
  gf = cgf_resource("#{onms_etc}/snmp-graph.properties.d/#{new_resource.file}").variables[:config]
  report = gf.report(short_name: new_resource.short_name)
  run_action(:create) if report.nil?
end

action :update do
  converge_if_changed do
    cgf_resource_init("#{onms_etc}/snmp-graph.properties.d/#{new_resource.file}")
    gf = cgf_resource("#{onms_etc}/snmp-graph.properties.d/#{new_resource.file}").variables[:config]
    report = gf.report(short_name: new_resource.short_name)
    raise Chef::Exceptions::ResourceNotFound, "No graph named #{new_resource.short_name} found in #{new_resource.file}. You must use action `:create` or `:create_if_missing` before updating." if report.nil?
    %i(long_name columns type command).each do |p|
      report[p.to_s] = new_resource.send(p) unless new_resource.send(p).nil?
    end
  end
end
action :delete do
  cgf_resource_init("#{onms_etc}/snmp-graph.properties.d/#{new_resource.file}")
  gf = cgf_resource("#{onms_etc}/snmp-graph.properties.d/#{new_resource.file}").variables[:config]
  report = gf.report(short_name: new_resource.short_name)
  converge_by "Removing graph #{new_resource.short_name} from #{new_resource.file}" do
    gf.delete_report(short_name: new_resource.short_name)
  end unless report.nil?
end

def whyrun_supported?
    true
end

use_inline_resources

action :create do
  Chef::Application.fatal!("Missing jdbc-collection #{@current_resource.collection_name}.") if !@current_resource.collection_exists
  Chef::Application.fatal!("Missing resourceType #{@current_resource.resource_type}.") if !@current_resource.resource_type_exists
  if @current_resource.exists
    Chef::Log.info "#{ @new_resource } already exists - nothing to do."
  else
    converge_by("Create #{ @new_resource }") do
      create_jdbc_query
      new_resource.updated_by_last_action(true)
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsJdbcQuery.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.collection_name(@new_resource.collection_name)
  @current_resource.resource_type(@new_resource.resource_type)

  if query_exists?(@current_resource.name, @current_resource.collection_name)
     @current_resource.exists = true
  end
  if collection_exists?(@current_resource.collection_name)
    @current_resource.collection_exists = true
  end
  exists, included = resource_type_exists_included(@current_resource.resource_type)
  @current_resource.resource_type_exists = exists && included
end


private

# I'm sure there's a better way than copy/pasting these private methods from resource_type to figure out if it exists aleady.
# returns the name of the group and the path of the file that contains resource_type 'name'.
def find_resource_type(name)
  group_name = nil
  Dir.foreach("#{node['opennms']['conf']['home']}/etc/datacollection") do |group|
    next if group !~ /.*\.xml$/
    file = ::File.new("#{node['opennms']['conf']['home']}/etc/datacollection/#{group}", "r")
    doc = REXML::Document.new file
    file.close
    exists = !doc.elements["/datacollection-group/resourceType[@name='#{name}']"].nil?
    if exists
      group_name = doc.elements["/datacollection-group"].attributes['name']
      break
    end
  end
  group_name
end

# returns the path of the file that contains group 'name'
def find_group(name)
  file_name = nil
  Dir.foreach("#{node['opennms']['conf']['home']}/etc/datacollection") do |group|
    next if group !~ /.*\.xml$/
    file = ::File.new("#{node['opennms']['conf']['home']}/etc/datacollection/#{group}", "r")
    doc = REXML::Document.new file
    file.close
    exists = !doc.elements["/datacollection-group[@name='#{name}']"].nil?
    if exists
      file_name = "#{node['opennms']['conf']['home']}/etc/datacollection/#{group}"
      break
    end
  end
  file_name
end

def resource_type_exists_included(name)
  Chef::Log.debug "Checking to see if this resource type exists: '#{ name }'"
  exists = false
  included = false
  group_name = find_resource_type(name)
  # check datacollection-config.xml to make sure the group is included in a snmp-collection
  if !group_name.nil?
    exists = true
    file = ::File.new("#{node['opennms']['conf']['home']}/etc/datacollection-config.xml", "r")
    doc = REXML::Document.new file
    file.close
    included = !doc.elements["/datacollection-config/snmp-collection/include-collection[@dataCollectionGroup='#{group_name}']"].nil?
  end
  [exists, included]
end

def collection_exists?(collection_name)
  Chef::Log.debug "Checking to see if this jdbc collection exists: '#{ collection_name }'"
  file = ::File.new("/opt/opennms/etc/jdbc-datacollection-config.xml", "r")
  doc = REXML::Document.new file
  !doc.elements["/jdbc-datacollection-config/jdbc-collection[@name='#{collection_name}']"].nil?
end

def query_exists?(name, collection_name)
  Chef::Log.debug "Checking to see if this jdbc query exists: '#{ name }'"
  file = ::File.new("/opt/opennms/etc/jdbc-datacollection-config.xml", "r")
  doc = REXML::Document.new file
  !doc.elements["/jdbc-datacollection-config/jdbc-collection[@name='#{collection_name}']/queries/query[@name='#{name}']"].nil?
end

def create_jdbc_query
  Chef::Log.debug "Creating jdbc query : '#{ new_resource.name }'"
  file = ::File.new("/opt/opennms/etc/jdbc-datacollection-config.xml", "r")
  contents = file.read
  doc = REXML::Document.new(contents, { :respect_whitespace => :all })
  doc.context[:attribute_quote] = :quote
  queries_el = doc.elements["/jdbc-datacollection-config/jdbc-collection[@name='#{new_resource.collection_name}']/queries"]
  if !queries_el.nil?
    query_el = queries_el.add_element 'query', {'name' => new_resource.name, 'ifType' => new_resource.if_type, 'recheckInterval' => new_resource.recheck_interval, 'resourceType' => new_resource.resource_type }
    if new_resource.instance_column
      query_el.add_attribute( 'instance-column' =>  new_resource.instance_column )
    end
    if new_resource.query_string
      statement_el = query_el.add_element 'statement'
      qs_el = statement_el.add_element 'queryString'
      qs_el.add_text(REXML::CData.new(new_resource.query_string))
    end
    if new_resource.columns
      columns_el = query_el.add_element 'columns'
      new_resource.columns.each { |name,details|
        column_el = columns_el.add_element 'column', { 'name' => name , 'type' => details['type'], 'alias' => details['alias'] }
        if details['data_source_name']
          column_el.add_attribute( 'data-source-name' => details['data_source_name'] )
        end
      }
    end

    out = ""
    formatter = REXML::Formatters::Pretty.new(2)
    formatter.compact = true
    formatter.write(doc, out)
    ::File.open("/opt/opennms/etc/jdbc-datacollection-config.xml", "w"){ |file| file.puts(out) }
  end
end

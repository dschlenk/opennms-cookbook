# frozen_string_literal: true
require 'rexml/document'
class JdbcQuery < Inspec.resource(1)
  name 'jdbc_query'

  desc '
    OpenNMS jdbc_query
  '

  example '
    describe jdbc_query(\'QUERY\', \'collection\') do
      it { should exist }
      its(\'if_type\') { should eq \'ignore\' }
      its(\'recheck_interval\') { should eq 7_200_000 }
      its(\'resource_type\') { should eq \'opennms_node\' }
      its(\'instance_column\') { should eq \'nodeid\' }
      its(\'query_string\') { should eq \'select ip.nodeid as nodeid,  count(if.serviceid) as service_count from ifservices if left join ipinterface ip on if.ipinterfaceid = ip.id group by ip.nodeid;\' }
      its(\'columns\') { should eq \'nodeid\' => { \'alias\' => \'nodeid\', \'type\' => \'string\' }, \'service_count\' => { \'alias\' => \'service_count\', \'type\' => \'gauge\' } }
    end
  '

  def initialize(query, collection)
    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/jdbc-datacollection-config.xml').content)
    q_el = doc.elements["/jdbc-datacollection-config/jdbc-collection[@name='#{collection}']/queries/query[@name='#{query}']"]
    @exists = !q_el.nil?
    @params = {}
    if @exists
      @params[:if_type] = q_el.attributes['ifType'].to_s
      @params[:recheck_interval] = q_el.attributes['recheckInterval'].to_s.to_i
      @params[:resource_type] = q_el.attributes['resourceType'].to_s
      @params[:instance_column] = q_el.attributes['instance-column'].to_s
      @params[:query_string] = q_el.elements['statement/queryString'].texts.join("\n")
      columns = {}
      q_el.each_element('columns/column') do |c_el|
        cname = c_el.attributes['name'].to_s
        ctype = c_el.attributes['type'].to_s
        calias = c_el.attributes['alias'].to_s
        cdsn = c_el.attributes['data-source-name'].to_s if c_el.attributes.key?('data-source-name')
        columns[cname] = { 'alias' => calias, 'type' => ctype } if cdsn.nil?
        columns[cname] = { 'alias' => calias, 'type' => ctype, 'data_source_name' => cdsn } unless cdsn.nil?
      end
      @params[:columns] = columns
    end
  end

  def exist?
    @exists
  end

  def method_missing(param)
    @params[param]
  end
end

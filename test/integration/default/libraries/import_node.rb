# frozen_string_literal: true
require 'rexml/document'
require 'rest_client'
class ImportNode < Inspec.resource(1)
  name 'import_node'

  desc '
    OpenNMS import_node
  '

  example '
    describe import_node(\'foreign_id\', \'foreign_source_name\') do
      it { should exist }
      its(\'node_label\') { should eq \'nodeA\' }
      its(\'parent_foreign_source\') { should eq \'foreign_source_name\' }
      its(\'parent_foreign_id\') { should eq \'parent_foreign_id\' }
      its(\'parent_node_label\') { should eq \'parent_nodelabel\' }
      its(\'building\') { should eq \'HQ\' }
      its(\'city\') { should eq \'Tulsa\' }
      its(\'categories\') { should eq [\'Servers\', \'Test\'] }
      its(\'assets\') { should eq { \'vendorPhone\' => \'411\' }
    end
  '

  def initialize(id, foreign_source_name)
    node = RestClient.get("http://admin:admin@localhost:8980/opennms/rest/requisitions/#{foreign_source_name}/nodes/#{id}")
    doc = REXML::Document.new(node)
    n_el = doc.elements["/node[@foreign-id = '#{id}']"]
    @exists = !n_el.nil?
    @params = {}
    @params[:node_label] = n_el.attributes['node-label']
    @params[:building] = n_el.attributes['building']
    @params[:city] = n_el.attributes['city']
    @params[:parent_foreign_source] = n_el.attributes['parent-foreign-source']
    @params[:parent_node_label] = n_el.attributes['parent-node-label']
    @params[:parent_foreign_id] = n_el.attributes['parent-foreign-id']
    assets = {}
    n_el.each_element("asset") do |a_el|
      assets[a_el.attributes['name']] = a_el.attributes['value']
    end
    @params[:assets] = assets
  end

  def exist?
    @exists
  end

  def method_missing(name)
    @params[name]
  end
end

# frozen_string_literal: true
require 'rexml/document'
require 'rest_client'
require 'addressable/uri'
class ImportNode < Inspec.resource(1)
  name 'import_node'

  desc '
    OpenNMS import_node
  '

  example '
    describe import_node(\'foreign_id\', \'foreign_source_name\', 1241) do
      it { should exist }
      its(\'node_label\') { should eq \'nodeA\' }
      its(\'parent_foreign_source\') { should eq \'foreign_source_name\' }
      its(\'parent_foreign_id\') { should eq \'parent_foreign_id\' }
      its(\'parent_node_label\') { should eq \'parent_nodelabel\' }
      its(\'building\') { should eq \'HQ\' }
      its(\'city\') { should eq \'Tulsa\' }
      its(\'categories\') { should eq [\'Servers\', \'Test\'] }
      its(\'assets\') { should eq { \'vendorPhone\' => \'411\' }
      its(\'meta_data\') { should eq [{ \'context\' => \'foo\' \'key\' => \'bar\', \'value\' => \'baz\'}]

    end
  '

  def initialize(id, foreign_source_name, port=8980)
    parsed_url = Addressable::URI.parse("http://admin:admin@localhost:#{port}/opennms/rest/requisitions/#{foreign_source_name}/nodes/#{id}").normalize.to_str
    begin
      node = RestClient.get(parsed_url)
    rescue StandardError
      puts "node #{id} in #{foreign_source_name} not found"
      @exists = false
      return
    end
    doc = REXML::Document.new(node)
    n_el = doc.elements["/node[@foreign-id = '#{id}']"]
    @exists = !n_el.nil?
    if @exists
      @params = {}
      @params[:node_label] = n_el.attributes['node-label']
      @params[:building] = n_el.attributes['building']
      @params[:city] = n_el.attributes['city']
      @params[:parent_foreign_source] = n_el.attributes['parent-foreign-source']
      @params[:parent_node_label] = n_el.attributes['parent-node-label']
      @params[:parent_foreign_id] = n_el.attributes['parent-foreign-id']
      categories = []
      n_el.each_element('category') do |c_el|
        categories.push c_el.attributes['name']
      end
      @params[:categories] = categories
      assets = {}
      n_el.each_element('asset') do |a_el|
        assets[a_el.attributes['name']] = a_el.attributes['value']
      end
      @params[:assets] = assets
      meta_data = {}
      meta_datas = []
      n_el.each_element('meta-data') do |a_el|
        a_el.each do |key, value|
          meta_data[key.to_s] = value
        end
        meta_datas.push (meta_data)
      end
      @params[:meta_data] = meta_datas
    end
  end

  def exist?
    @exists
  end

  def method_missing(name)
    @params[name]
  end
end

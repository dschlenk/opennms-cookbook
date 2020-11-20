# frozen_string_literal: true
require 'rexml/document'

class WsManGroup < Inspec.resource(1)
  name 'wsman_group'

  desc '
    OpenNMS wsman_group
  '

  example '
    describe wsman_group(\'wmi_test_resource\) do
      it { should exist }
      its(\'name\') { should eq \'wsman-another-group\' }
      its(\'resource_type\') { should eq \'node\' }
      its(\'resource_uri\') { should eq \'http://schemas.test.group.com/\' }
      its(\'attribs\') { should eq \'resource\' => { \'alias\' => \'resource\', \'type\' => \'string\' }, \'metric\' => { \'alias\' => \'metric\', \'type\' => \'gauge\' } }
    end
  '

  def initialize(name, file)
    doc = REXML::Document.new(inspec.file("/opt/opennms/etc/#{file}").content)
    group = doc.elements["/wsman-datacollection-config/group[@name='#{name}']"]

    @exists = !group.nil?
    @params = {}

    if @exists
      @params[:group_name] = group.attributes['name'].to_s
      @params[:resource_type] = group.attributes['resource-type'].to_s
      @params[:resource_uri] = group.attributes['resource-uri'].to_s

      unless group.attributes['dialect'].nil?
        @params[:dialect] = group.attributes['dialect'].to_s
      end
      unless group.attributes['filter'].nil?
        @params[:filter] = group.attributes['filter'].to_s
      end
      unless group.elements['attrib'].nil?
        attribs = []
        group.each_element('attrib') do |a|
          na = {}

          na['name'] = a.attributes['name'].to_s
          na['type'] = a.attributes['type'].to_s
          na['alias'] = a.attributes['alias'].to_s
          na['index-of'] = a.attributes['index-of'] unless a.attributes['index-of'].nil?
          na['filter'] = a.attributes['filter'].to_s unless a.attributes['filter'].nil?

          attribs.push na
        end
      end
      @params[:attribs] = attribs
    end
  end

  def exist?
    @exists
  end

  def method_missing(param)
    @params[param]
  end
end

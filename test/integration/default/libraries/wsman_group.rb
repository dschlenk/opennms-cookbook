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
      puts 'Group Name : ' + group.attributes["name"].to_s
      @params[:group_name] = group.attributes["name"].to_s
      puts 'Resource Type : ' + group.attributes["resource-type"].to_s
      @params[:resource_type] = group.attributes["resource-type"].to_s
      puts 'Resource URL : ' + group.attributes["resource-uri"].to_s
      @params[:resource_uri] = group.attributes["resource-uri"].to_s

      unless group.attributes["dialect"].nil?
        puts 'dialect : ' + group.attributes["dialect"].to_s
        @params[:dialect] = group.attributes["dialect"].to_s
      end
      unless group.attributes["filter"].nil?
        puts 'filter : ' + group.attributes["filter"].to_s
        @params[:filter] = group.attributes["filter"].to_s
      end
      unless group.elements['attrib'].nil?
        attribs = {}
        group.each_element('attrib') do |a|
          aname = a.attributes['name'].to_s
          puts 'attributes name : ' + aname
          atype = a.attributes['type'].to_s
          puts 'attributes type : ' + atype
          aalias = a.attributes['alias'].to_s
          puts 'attributes alias : ' + aalias

          unless a.attributes['index-of'].nil?
            aido = a.attributes['index-of'].to_s
            puts 'attributes index-of : ' + aido
          end

          unless a.attributes['filter'].nil?
            afilter = a.attributes['filter'].to_s
            puts 'attributes index-of : ' + afilter
          end

          attribs[aname] = {}
          attribs[aname]['type'] = atype
          attribs[aname]['alias'] = aalias

          unless aido.nil?
            attribs[aname]['index-of'] = aido
          end

          unless afilter.nil?
            attribs[aname]['filter'] = afilter
          end
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

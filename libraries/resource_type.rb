# frozen_string_literal: true
module ResourceType
  class ResourceTypeClass
    def resource_type_exists_included(onms_home, name)
      # take care of the built-in resource types
      if name == 'node' || name == 'nodeSnmp' || name == 'interfaceSnmp' || name == 'domain' || name == 'nodeSource' || name == 'responseTime' || name == 'distributedStatus'
        return [true, true]
      end
      Chef::Log.debug "Checking to see if this resource type exists: '#{name}'"
      exists = false
      included = false
      group_name = find_resource_type(onms_home, name)

      unless group_name.nil?
        exists = true
        file = ::File.new("#{onms_home}/etc/datacollection-config.xml", 'r')
        doc = REXML::Document.new file
        file.close
        included = !doc.elements["/datacollection-config/snmp-collection/include-collection[@dataCollectionGroup='#{group_name}']"].nil?
      end
      [exists, included]
    end

    # returns the name of the group and the path of the file that contains resource_type 'name'.
    def find_resource_type(onms_home, name)
      group_name = nil
      Dir.foreach("#{onms_home}/etc/datacollection") do |group|
        next if group !~ /.*\.xml$/
        file = ::File.new("#{onms_home}/etc/datacollection/#{group}", 'r')
        doc = REXML::Document.new file
        file.close
        exists = !doc.elements["/datacollection-group/resourceType[@name='#{name}']"].nil?
        if exists
          group_name = doc.elements['/datacollection-group'].attributes['name']
          break
        end
      end
      group_name
    end

    # returns the path of the file that contains group 'name'
    def find_group(onms_home, name)
      file_name = nil
      Dir.foreach("#{onms_home}/etc/datacollection") do |group|
        next if group !~ /.*\.xml$/
        file = ::File.new("#{onms_home}/etc/datacollection/#{group}", 'r')
        doc = REXML::Document.new file
        file.close
        exists = !doc.elements["/datacollection-group[@name='#{name}']"].nil?
        if exists
          file_name = "#{onms_home}/etc/datacollection/#{group}"
          break
        end
      end
      file_name
    end
  end

  def rt_exists?(onms_home, name)
    rtc = ResourceTypeClass.new
    exists, _included = rtc.resource_type_exists_included(onms_home, name)
    exists
  end

  def rt_included?(onms_home, name)
    rtc = ResourceTypeClass.new
    _exists, included = rtc.resource_type_exists_included(onms_home, name)
    included
  end

  def find_resource_type(onms_home, name)
    rtc = ResourceTypeClass.new
    rtc.find_resource_type(onms_home, name)
  end

  def find_group(onms_home, name)
    rtc = ResourceTypeClass.new
    rtc.find_group(onms_home, name)
  end
end

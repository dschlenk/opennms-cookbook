module Opennms
  module Cookbook
    module Collection
      module SnmpCollectionTemplate
        def snmp_resource_init
          snmp_resource_create unless snmp_resource_exist?
        end

        def snmp_resource
          return unless snmp_resource_exist?
          find_resource!(:template, "#{onms_etc}/datacollection-config.xml")
        end

        # avoid parsing the file every time when nothing changes
        def ro_snmp_resource_init
          ro_snmp_resource_create unless ro_snmp_resource_exist?
        end

        def ro_snmp_resource
          return unless ro_snmp_resource_exist?
          find_resource!(:template, "RO #{onms_etc}/datacollection-config.xml")
        end

        private

        def snmp_resource_exist?
          !find_resource(:template, "#{onms_etc}/datacollection-config.xml").nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def snmp_resource_create
          file = Opennms::Cookbook::Collection::OpennmsCollectionConfigFile.new
          file.read!("#{onms_etc}/datacollection-config.xml", 'snmp')
          with_run_context(:root) do
            declare_resource(:template, "#{onms_etc}/datacollection-config.xml") do
              cookbook 'opennms'
              source 'datacollection-config.xml.erb'
              owner node['opennms']['username']
              group node['opennms']['groupname']
              mode '0664'
              variables(
                collections: file.collections,
                rrd_base_dir: node['opennms']['properties']['dc']['rrd_base_dir'],
                rrd_dc_dir: node['opennms']['properties']['dc']['rrd_dc_dir']
              )
              action :nothing
              delayed_action :create
            end
          end
        end

        def ro_snmp_resource_exist?
          !find_resource(:template, "RO #{onms_etc}/datacollection-config.xml").nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def ro_snmp_resource_create
          file = Opennms::Cookbook::Collection::OpennmsCollectionConfigFile.new
          file.read!("#{onms_etc}/datacollection-config.xml", 'snmp')
          with_run_context(:root) do
            declare_resource(:template, "RO #{onms_etc}/datacollection-config.xml") do
              path "#{Chef::Config[:file_cache_path]}/datacollection-config.xml"
              cookbook 'opennms'
              source 'datacollection-config.xml.erb'
              owner node['opennms']['username']
              group node['opennms']['groupname']
              mode '0664'
              variables(
                collections: file.collections,
                rrd_base_dir: node['opennms']['properties']['dc']['rrd_base_dir'],
                rrd_dc_dir: node['opennms']['properties']['dc']['rrd_dc_dir']
              )
              action :nothing
              delayed_action :nothing
            end
          end
        end
      end

      module JdbcCollectionTemplate
        def jdbc_resource_init
          jdbc_resource_create unless jdbc_resource_exist?
        end

        def jdbc_resource
          return unless jdbc_resource_exist?
          find_resource!(:template, "#{onms_etc}/jdbc-datacollection-config.xml")
        end

        def ro_jdbc_resource_init
          ro_jdbc_resource_create unless ro_jdbc_resource_exist?
        end

        def ro_jdbc_resource
          return unless ro_jdbc_resource_exist?
          find_resource!(:template, "RO #{onms_etc}/jdbc-datacollection-config.xml")
        end

        private

        def jdbc_resource_exist?
          !find_resource(:template, "#{onms_etc}/jdbc-datacollection-config.xml").nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def jdbc_resource_create
          file = Opennms::Cookbook::Collection::OpennmsCollectionConfigFile.new
          file.read!("#{onms_etc}/jdbc-datacollection-config.xml", 'jdbc')
          with_run_context(:root) do
            declare_resource(:template, "#{onms_etc}/jdbc-datacollection-config.xml") do
              cookbook 'opennms'
              source 'jdbc-datacollection-config.xml.erb'
              owner node['opennms']['username']
              group node['opennms']['groupname']
              mode '0664'
              variables(
                collections: file.collections,
                rrd_repository: node['opennms']['jdbc_dc']['rrd_repository']
              )
              action :nothing
              delayed_action :create
              notifies :restart, 'service[opennms]'
            end
          end
        end

        def ro_jdbc_resource_exist?
          !find_resource(:template, "RO #{onms_etc}/jdbc-datacollection-config.xml").nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def ro_jdbc_resource_create
          file = Opennms::Cookbook::Collection::OpennmsCollectionConfigFile.new
          file.read!("#{onms_etc}/jdbc-datacollection-config.xml", 'jdbc')
          with_run_context(:root) do
            declare_resource(:template, "RO #{onms_etc}/jdbc-datacollection-config.xml") do
              path "#{Chef::Config[:file_cache_path]}/jdbc-datacollection-config.xml"
              cookbook 'opennms'
              source 'jdbc-datacollection-config.xml.erb'
              owner node['opennms']['username']
              group node['opennms']['groupname']
              mode '0664'
              variables(
                collections: file.collections
              )
              action :nothing
              delayed_action :nothing
            end
          end
        end
      end

      module JmxCollectionTemplate
        def jmx_resource_init
          jmx_resource_create unless jmx_resource_exist?
        end

        def jmx_resource
          return unless jmx_resource_exist?
          find_resource!(:template, "#{onms_etc}/jmx-datacollection-config.xml")
        end

        def ro_jmx_resource_init
          ro_jmx_resource_create unless ro_jmx_resource_exist?
        end

        def ro_jmx_resource
          return unless ro_jmx_resource_exist?
          find_resource!(:template, "RO #{onms_etc}/jmx-datacollection-config.xml")
        end

        private

        def jmx_resource_exist?
          !find_resource(:template, "#{onms_etc}/jmx-datacollection-config.xml").nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def jmx_resource_create
          file = Opennms::Cookbook::Collection::OpennmsCollectionConfigFile.new
          file.read!("#{onms_etc}/jmx-datacollection-config.xml", 'jmx')
          with_run_context(:root) do
            declare_resource(:template, "#{onms_etc}/jmx-datacollection-config.xml") do
              cookbook 'opennms'
              source 'jmx-datacollection-config.xml.erb'
              owner node['opennms']['username']
              group node['opennms']['groupname']
              mode '0664'
              variables(
                collections: file.collections,
                rrd_repository: node['opennms']['jmx_dc']['rrd_repository']
              )
              action :nothing
              delayed_action :create
              notifies :restart, 'service[opennms]'
            end
          end
        end

        def ro_jmx_resource_exist?
          !find_resource(:template, "RO #{onms_etc}/jmx-datacollection-config.xml").nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def ro_jmx_resource_create
          file = Opennms::Cookbook::Collection::OpennmsCollectionConfigFile.new
          file.read!("#{onms_etc}/jmx-datacollection-config.xml", 'jmx')
          with_run_context(:root) do
            declare_resource(:template, "RO #{onms_etc}/jmx-datacollection-config.xml") do
              path "#{Chef::Config[:file_cache_path]}/jmx-datacollection-config.xml"
              cookbook 'opennms'
              source 'jmx-datacollection-config.xml.erb'
              owner node['opennms']['username']
              group node['opennms']['groupname']
              mode '0664'
              variables(
                collections: file.collections
              )
              action :nothing
              delayed_action :nothing
            end
          end
        end
      end

      module WsmanCollectionTemplate
        def wsman_resource_init(file)
          wsman_resource_create(file) unless wsman_resource_exist?(file)
        end

        def wsman_resource(file)
          return unless wsman_resource_exist?(file)
          find_resource!(:template, file)
        end

        def ro_wsman_resource_init(file)
          ro_wsman_resource_create(file) unless ro_wsman_resource_exist?(file)
        end

        def ro_wsman_resource(file)
          return unless ro_wsman_resource_exist?(file)
          find_resource!(:template, "RO #{file}")
        end

        private

        def wsman_resource_exist?(file)
          !find_resource(:template, file).nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def wsman_resource_create(file)
          f = Opennms::Cookbook::Collection::WsmanCollectionConfigFile.new
          f.read!(file, 'wsman')
          with_run_context(:root) do
            declare_resource(:template, file) do
              cookbook 'opennms'
              source 'wsman-datacollection-config.xml.erb'
              owner node['opennms']['username']
              group node['opennms']['groupname']
              mode '0664'
              variables(
                collections: f.collections,
                rrd_repository: node['opennms']['wsman_dc']['rrd_repository'],
                groups: f.groups,
                system_definitions: f.system_definitions
              )
              action :nothing
              delayed_action :create
              notifies :restart, 'service[opennms]'
            end
          end
        end

        def ro_wsman_resource_exist?(file)
          !find_resource(:template, "RO #{file}").nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def ro_wsman_resource_create(file)
          f = Opennms::Cookbook::Collection::WsmanCollectionConfigFile.new
          f.read!(file, 'wsman')
          with_run_context(:root) do
            declare_resource(:template, "RO #{file}") do
              path "#{Chef::Config[:file_cache_path]}/#{file}"
              cookbook 'opennms'
              source 'wsman-datacollection-config.xml.erb'
              owner node['opennms']['username']
              group node['opennms']['groupname']
              mode '0664'
              variables(
                collections: f.collections,
                rrd_repository: node['opennms']['wsman_dc']['rrd_repository'],
                groups: f.groups,
                system_definitions: f.system_definitions
              )
              action :nothing
              delayed_action :nothing
            end
          end
        end
      end

      module XmlCollectionTemplate
        def xml_resource_init
          xml_resource_create unless xml_resource_exist?
        end

        def xml_resource
          return unless xml_resource_exist?
          find_resource!(:template, "#{onms_etc}/xml-datacollection-config.xml")
        end

        def ro_xml_resource_init
          ro_xml_resource_create unless ro_xml_resource_exist?
        end

        def ro_xml_resource
          return unless ro_xml_resource_exist?
          find_resource!(:template, "RO #{onms_etc}/xml-datacollection-config.xml")
        end

        def import_groups_resources
          new_resource.import_groups.each do |ig|
            case new_resource.import_groups_source
            when 'cookbook_file'
              declare_resource(:cookbook_file, "#{onms_etc}/xml-datacollection/#{ig}") do
                owner node['opennms']['username']
                group node['opennms']['groupname']
                mode '0644'
                source ig
                action :create
              end
            when 'external'
              Chef::Log.debug("Not managing XML Group file #{ig} for #{new_resource.url} in collection #{new_resource.collection_name}")
            else
              declare_resource(:remote_file, "#{onms_etc}/xml-datacollection/#{ig}") do
                owner node['opennms']['username']
                group node['opennms']['groupname']
                mode '0644'
                source "#{new_resource.import_groups_source}/#{ig}"
                action :create
              end
            end
          end
        end

        def delete_import_groups_files
          new_resource.import_groups.each do |ig|
            declare_resource(:file, "#{onms_etc}/xml-datacollection/#{ig}") do
              action :delete
            end
          end unless new_resource.import_groups_source.eql?('external')
        end

        private

        def xml_resource_exist?
          !find_resource(:template, "#{onms_etc}/xml-datacollection-config.xml").nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def xml_resource_create
          file = Opennms::Cookbook::Collection::OpennmsCollectionConfigFile.new
          file.read!("#{onms_etc}/xml-datacollection-config.xml", 'xml')

          with_run_context(:root) do
            declare_resource(:template, "#{onms_etc}/xml-datacollection-config.xml") do
              cookbook 'opennms'
              source 'xml-datacollection-config.xml.erb'
              owner node['opennms']['username']
              group node['opennms']['groupname']
              mode '0644'
              variables(collections: file.collections)
              action :nothing
              delayed_action :create
              notifies :restart, 'service[opennms]'
            end
          end
        end

        def ro_xml_resource_exist?
          !find_resource(:template, "RO #{onms_etc}/xml-datacollection-config.xml").nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def ro_xml_resource_create
          file = Opennms::Cookbook::Collection::OpennmsCollectionConfigFile.new
          file.read!("#{onms_etc}/xml-datacollection-config.xml", 'xml')
          with_run_context(:root) do
            declare_resource(:template, "RO #{onms_etc}/xml-datacollection-config.xml") do
              path "#{Chef::Config[:file_cache_path]}/xml-datacollection-config.xml"
              cookbook 'opennms'
              source 'xml-datacollection-config.xml.erb'
              owner node['opennms']['username']
              group node['opennms']['groupname']
              mode '0644'
              variables(collections: file.collections)
              action :nothing
              delayed_action :nothing
            end
          end
        end
      end

      module ResourceTypeTemplate
        def rt_resource_init(file)
          rt_resource_create(file) unless rt_resource_exist?(file)
        end

        def rt_resource(file)
          return unless rt_resource_exist?(file)
          find_resource!(:template, file)
        end

        def ro_rt_resource_init(file)
          ro_rt_resource_create(file) unless ro_rt_resource_exist?(file)
        end

        def ro_rt_resource(file)
          return unless ro_rt_resource_exist?(file)
          find_resource!(:template, "RO #{file}")
        end

        private

        def rt_resource_exist?(file)
          !find_resource(:template, file).nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def rt_resource_create(file)
          f = Opennms::Cookbook::Collection::ResourceTypeConfigFile.new
          f.read!(file)
          with_run_context(:root) do
            declare_resource(:template, file) do
              cookbook 'opennms'
              source 'resource-types.xml.erb'
              owner node['opennms']['username']
              group node['opennms']['groupname']
              mode '0644'
              variables(config: f)
              action :nothing
              delayed_action :create
              notifies :restart, 'service[opennms]'
            end
          end
        end

        def ro_rt_resource_exist?(file)
          !find_resource(:template, "RO #{file}").nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def ro_rt_resource_create(file)
          f = Opennms::Cookbook::Collection::ResourceTypeConfigFile.new
          f.read!(file)
          with_run_context(:root) do
            declare_resource(:template, "RO #{file}") do
              path "#{Chef::Config[:file_cache_path]}/#{file}"
              cookbook 'opennms'
              source 'resource-types.xml.erb'
              owner node['opennms']['username']
              group node['opennms']['groupname']
              mode '0644'
              variables(config: f)
              action :nothing
              delayed_action :nothing
            end
          end
        end
      end

      module GroupResourceTypeTemplate
        def rtgroup_resource_init(file, group_name = nil)
          rtgroup_resource_create(file, group_name) unless rtgroup_resource_exist?(file)
        end

        def rtgroup_resource(file)
          return unless rtgroup_resource_exist?(file)
          find_resource!(:template, file)
        end

        def ro_rtgroup_resource_init(file, group_name = nil)
          ro_rtgroup_resource_create(file, group_name) unless ro_rtgroup_resource_exist?(file)
        end

        def ro_rtgroup_resource(file)
          return unless ro_rtgroup_resource_exist?(file)
          find_resource!(:template, "RO #{file}")
        end

        private

        def rtgroup_resource_exist?(file)
          !find_resource(:template, file).nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def rtgroup_resource_create(file, group_name)
          f = Opennms::Cookbook::Collection::CollectionGroupConfigFile.new(group_name: group_name)
          f.read!(file)
          with_run_context(:root) do
            declare_resource(:template, file) do
              cookbook 'opennms'
              source 'datacollection-group.xml.erb'
              owner node['opennms']['username']
              group node['opennms']['groupname']
              mode '0644'
              variables(config: f)
              action :nothing
              delayed_action :create
              notifies :restart, 'service[opennms]'
            end
          end
        end

        def ro_rtgroup_resource_exist?(file)
          !find_resource(:template, "RO #{file}").nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def ro_rtgroup_resource_create(file, group_name)
          f = Opennms::Cookbook::Collection::CollectionGroupConfigFile.new(group_name: group_name)
          f.read!(file)
          with_run_context(:root) do
            declare_resource(:template, "RO #{file}") do
              path "#{Chef::Config[:file_cache_path]}/#{file}"
              cookbook 'opennms'
              source 'datacollection-group.xml.erb'
              owner node['opennms']['username']
              group node['opennms']['groupname']
              mode '0644'
              variables(config: f)
              action :nothing
              delayed_action :nothing
            end
          end
        end
      end

      class ResourceTypeConfigFile
        include Opennms::XmlHelper
        attr_reader :resource_types

        def initialize(xpath = 'resource-types')
          @resource_types = []
          @xpath = xpath
        end

        def read!(file = 'resource-type.xml')
          return unless ::File.exist?(file)

          doc = xmldoc_from_file(file)
          @resource_types = SnmpCollectionUtils.resource_types(doc.elements[@xpath])
        end

        def resource_type(name:)
          rts = @resource_types.select { |rt| rt[:name].eql?(name) }
          return if rts.nil? || rts.empty?
          raise DuplicateResourceType, "More than one resourceType with name #{name} found" unless rts.one?
          rts.pop
        end

        def resource_type_update(name:, label:, resource_label:, persistence_selector_strategy:, persistence_selector_strategy_params:, storage_strategy:, storage_strategy_params:)
          @resource_types.map do |rt|
            next unless rt[:name].eql?(name)
            rt[:label] = label unless label.nil?
            rt[:resource_label] = resource_label unless resource_label.nil?
            rt[:persistence_selector_strategy][:class] = persistence_selector_strategy unless persistence_selector_strategy.nil?
            rt[:persistence_selector_strategy][:parameters] = persistence_selector_strategy_params unless persistence_selector_strategy_params.nil?
            rt[:storage_strategy][:class] = storage_strategy unless storage_strategy.nil?
            rt[:storage_strategy][:parameters] = storage_strategy_params unless storage_strategy_params.nil?
            break
          end
        end

        def resource_type_delete(name:)
          @resource_types.delete_if { |rt| rt[:name].eql?(name) }
        end

        def system_def_update(name:, sysoid: nil, sysoid_mask: nil, ip_addrs: nil, ip_addr_masks: nil, include_groups: nil)
          @system_defs.map do |sd|
            next unless sd[:name].eql?(name)
            sd[:sysoid] = sysoid unless sysoid.nil?
            sd[:sysoid_mask] = sysoid_mask unless sysoid_mask.nil?
            sd[:ip_addrs] = ip_addrs unless ip_addrs.nil?
            sd[:ip_addr_masks] = ip_addr_masks unless ip_addr_masks.nil?
            sd[:include_groups] = include_groups unless include_groups.nil?
            break
          end
        end

        def system_def_delete(name:)
          @system_defs.delete_if { |sd| sd[:name].eql?(name) }
        end

        def self.read(file = 'resource-type.xml')
          cf = ResourceTypeConfigFile.new
          cf.read!(file)
          cf
        end
      end

      class CollectionGroupConfigFile < ResourceTypeConfigFile
        include Opennms::XmlHelper
        attr_reader :group_name, :groups, :system_defs

        def initialize(group_name: nil)
          super('datacollection-group')
          @group_name = group_name
          @groups = []
          @system_defs = []
        end

        def read!(file = 'datacollection-group.xml')
          return unless ::File.exist?(file)
          super

          doc = xmldoc_from_file(file)
          @group_name = doc.elements[@xpath].attributes['name']
          @groups = SnmpCollectionUtils.groups(doc.elements[@xpath], 'group')
          @system_defs = SnmpCollectionUtils.system_defs(doc.elements[@xpath], 'systemDef')
        end

        def group(name:)
          groups = @groups.select { |group| group[:name].eql?(name) }
          return if groups.nil? || groups.empty?
          raise DuplicateSnmpGroup, "More than one group with name #{name} found" unless groups.one?
          groups.pop
        end

        def system_def(name:)
          sds = @system_defs.select { |sd| sd[:name].eql?(name) }
          return if sds.nil? || sds.empty?
          raise DuplicatedSystemDefinition, "More than one systemDef with name #{name} found" unless sds.one?
          sds.pop
        end

        def self.read(file = 'resource-type.xml')
          cf = CollectionGroupConfigFile.new
          cf.read!(file)
          cf
        end
      end

      class OpennmsCollectionConfigFile
        include Opennms::XmlHelper
        attr_reader :collections

        def initialize
          @collections = {}
        end

        def read!(file = 'datacollection-config.xml', type)
          raise ArgumentError, "File #{file} does not exist" unless ::File.exist?(file)

          doc = xmldoc_from_file(file)
          prefix = case type
                   when 'snmp'
                     ''
                   else
                     "#{type}-"
                   end
          cel = "#{type}-collection"
          cel = 'collection' if type.eql?('wsman')
          doc.each_element("#{prefix}datacollection-config/#{cel}") do |c|
            name = c.attributes['name']
            rrd_step = c.elements['rrd/@step'].value.to_i
            rras = []
            c.each_element('rrd/rra') do |rra|
              rras.push xml_element_text(rra)
            end
            @collections[name] = OpennmsCollection.create(name: name, type: type, rrd_step: rrd_step, rras: rras)
            @collections[name].type_config(c)
          end
        end

        def to_s
          @collections.map(&:to_s).join("\n")
        end

        def add(c)
          @collections[c.name] = c
        end

        def remove(c)
          @collections.delete(c.name)
        end

        def include?(c)
          @collections.any? { |c2| c.eql?(c2) }
        end

        def self.read(file = 'datacollection-config.xml', type)
          cf = OpennmsCollectionConfigFile.new
          cf.read!(file, type)
          cf
        end
      end

      class WsmanCollectionConfigFile < OpennmsCollectionConfigFile
        attr_reader :groups, :system_definitions
        def initialize
          super
          @groups = []
          @system_definitions = []
        end

        def read!(file, type)
          unless ::File.exist?(file)
            doc = REXML::Document.new
            doc << REXML::XMLDecl.new
            root_el = doc.add_element 'wsman-datacollection-config'
            root_el.add_text("\n")
            Opennms::Helpers.write_xml_file(doc, file)
          end
          super
          doc = xmldoc_from_file(file)
          doc.each_element('wsman-datacollection-config/group') do |group|
            attribs = []
            group.each_element('attrib') do |attrib|
              attribs.push({ 'name' => attrib.attributes['name'], 'alias' => attrib.attributes['alias'], 'type' => attrib.attributes['type'], 'index-of' => attrib.attributes['index-of'], 'filter' => attrib.attributes['filter'] }.compact)
            end
            @groups.push(WsmanGroup.new(name: group.attributes['name'], resource_uri: group.attributes['resource-uri'], resource_type: group.attributes['resource-type'], dialect: group.attributes['dialect'], filter: group.attributes['filter'], attribs: attribs))
          end
          doc.each_element('wsman-datacollection-config/system-definition') do |sd|
            @system_definitions.push(WsmanSystemDefinition.new(name: sd.attributes['name'], rule: xml_element_text(sd, 'rule'), include_groups: xml_text_array(sd, 'include-group')))
          end
        end

        def self.read(file, type)
          cf = WsmanCollectionConfigFile.new
          cf.read!(file, type)
          cf
        end
      end

      module XmlCollectionGroupsTemplate
        def groupsfile_resource_init(file)
          groupsfile_resource_create(file) unless groupsfile_resource_exist?(file)
        end

        def groupsfile_resource(file)
          return unless groupsfile_resource_exist?(file)
          find_resource!(:template, "#{onms_etc}/xml-datacollection/#{file}")
        end

        def ro_groupsfile_resource_init(file)
          ro_groupsfile_resource_create(file) unless ro_groupsfile_resource_exist?(file)
        end

        def ro_groupsfile_resource(file)
          return unless ro_groupsfile_resource_exist?(file)
          find_resource!(:template, "RO #{onms_etc}/xml-datacollection/#{file}")
        end

        private

        def groupsfile_resource_exist?(file)
          !find_resource(:template, "#{onms_etc}/xml-datacollection/#{file}").nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def groupsfile_resource_create(file)
          groupsfile = Opennms::Cookbook::Collection::OpennmsCollectionXmlGroupsFile.new
          groupsfile.read!("#{onms_etc}/xml-datacollection/#{file}") if ::File.exist?("#{onms_etc}/xml-datacollection/#{file}")
          with_run_context(:root) do
            declare_resource(:template, "#{onms_etc}/xml-datacollection/#{file}") do
              cookbook 'opennms'
              source 'xml-groups.xml.erb'
              owner node['opennms']['username']
              group node['opennms']['groupname']
              mode '0644'
              variables(groupsfile: groupsfile)
              action :nothing
              delayed_action :create
              notifies :restart, 'service[opennms]'
            end
          end
        end

        def ro_groupsfile_resource_exist?(file)
          !find_resource(:template, "RO #{onms_etc}/xml-datacollection/#{file}").nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def ro_groupsfile_resource_create(file)
          groupsfile = Opennms::Cookbook::Collection::OpennmsCollectionXmlGroupsFile.new
          groupsfile.read!("#{onms_etc}/xml-datacollection/#{file}") if ::File.exist?("#{onms_etc}/xml-datacollection/#{file}")
          with_run_context(:root) do
            declare_resource(:template, "RO #{onms_etc}/xml-datacollection/#{file}") do
              path "#{Chef::Config[:file_cache_path]}/xml-datacollection-#{file}"
              cookbook 'opennms'
              source 'xml-groups.xml.erb'
              owner node['opennms']['username']
              group node['opennms']['groupname']
              mode '0644'
              variables(groupsfile: groupsfile)
              action :nothing
              delayed_action :nothing
            end
          end
        end
      end

      class OpennmsCollectionXmlGroupsFile
        include Opennms::XmlHelper
        attr_reader :groups

        def initialize
          @groups = []
        end

        def read!(file = 'datacollection-config.xml')
          raise ArgumentError, "File #{file} does not exist" unless ::File.exist?(file)
          doc = xmldoc_from_file(file)
          @groups = XmlCollection.groups_from_element(doc, '/xml-groups/xml-group') || []
        end

        def to_s
          @groups.map(&:to_s).join("\n")
        end

        def add(g)
          @groups.push = g
        end

        def remove(group)
          @groups.delete_if { |g| g['name'].eql?(group['name']) }
        end

        def group(name:)
          gn = @groups.filter { |g| g['name'].eql?(name) }
          return if gn.nil? || gn.empty?
          raise DuplicateXmlGroup, "More than one group named #{name} found in file" unless gn.one?
          gn.pop
        end

        def self.read(file = 'datacollection-config.xml')
          cf = OpennmsCollectionXmlGroupsFile.new
          cf.read!(file)
          cf
        end
      end

      class OpennmsCollection
        include Opennms::XmlHelper
        attr_reader :name, :rrd_step, :rras, :type

        def initialize(name:, type:, rrd_step: nil, rras: nil)
          @name = name
          @name.freeze
          @type = type
          @type.freeze
          @rrd_step = rrd_step || 300
          @rras = rras || ['RRA:AVERAGE:0.5:1:2016', 'RRA:AVERAGE:0.5:12:1488', 'RRA:AVERAGE:0.5:288:366', 'RRA:MAX:0.5:288:366', 'RRA:MIN:0.5:288:366']
        end

        def to_s
          "name: #{@name}\n" \
            "type: #{@type}\n" \
            "rrd_step: #{@rrd_step}\n" \
            "rras: #{@rras}"
        end

        def eql?(c)
          return false unless self.class.eql?(c.class)
          name.eql?(c.name) && type.eql?(c.type) && rrd_step.eql?(c.rrd_step) && rras.eql?(c.rras)
        end

        def match?(c)
          name.eql?(c.name) && type.eql?(c.type)
        end

        def update(rrd_step: nil, rras: nil)
          @rrd_step = rrd_step unless rrd_step.nil?
          @rras = rras unless rras.nil?
        end

        def type_config(_c)
          raise 'Unimplemented method'
        end

        def self.create(**properties)
          case properties.fetch(:type)
          when 'xml'
            XmlCollection.new(**properties)
          when 'snmp'
            SnmpCollection.new(**properties)
          when 'jdbc'
            JdbcCollection.new(**properties)
          when 'jmx'
            JmxCollection.new(**properties)
          when 'wsman'
            WsmanCollection.new(**properties)
          end
        end
      end

      class XmlHelper
        include Opennms::XmlHelper
      end

      module SnmpCollectionUtils
        def self.resource_types(c)
          resource_types = []
          c.each_element('resourceType') do |rt|
            name = rt.attributes['name']
            label = rt.attributes['label']
            resource_label = rt.attributes['resourceLabel']
            pss_params = []
            rt.each_element('persistenceSelectorStrategy/parameter') do |rtp|
              pss_params.push({ rtp.attributes['key'] => rtp.attributes['value'] })
            end
            pss_class = rt.elements['persistenceSelectorStrategy/@class'].value
            ss_params = []
            rt.each_element('storageStrategy/parameter') do |rtp|
              ss_params.push({ rtp.attributes['key'] => rtp.attributes['value'] })
            end
            ss_class = rt.elements['storageStrategy/@class'].value
            resource_types.push({ name: name, label: label, resource_label: resource_label, persistence_selector_strategy: { class: pss_class, parameters: pss_params }, storage_strategy: { class: ss_class, parameters: ss_params } }.compact)
          end
          resource_types
        end

        def self.groups(c, xpath)
          xh = XmlHelper.new
          groups = []
          c.each_element(xpath) do |g|
            mib_objs = []
            g.each_element('mibObj') do |mo|
              mib_objs.push({ oid: mo.attributes['oid'], instance: mo.attributes['instance'], alias: mo.attributes['alias'], type: mo.attributes['type'], maxval: mo.attributes['maxval'], minval: mo.attributes['minval'] })
            end
            subgroups = []
            g.each_element('includeGroup') do |ig|
              subgroups.push(xh.xml_element_text(ig))
            end
            properties = []
            g.each_element('property') do |p|
              pp = {}
              p.each_element['parameter'] do |ppp|
                pp[ppp.attributes['key']] = ppp.attributes['value']
              end
              properties.push({ instance: p.attributes['instance'], alias: p.attributes['alias'], class_name: p.attributes['class-name'], parameters: pp }.compact)
            end
            groups.push({ name: g.attributes['name'], if_type: g.attributes['ifType'], mib_objs: mib_objs, include_groups: subgroups, properties: properties }.compact)
          end
          groups
        end

        def self.system_defs(c, xpath)
          xh = XmlHelper.new
          systems = []
          c.each_element(xpath) do |sd|
            systems.push({ name: sd.attributes['name'],
                           sysoid: xh.xml_element_text(sd.elements['sysoid']),
                           sysoid_mask: xh.xml_element_text(sd.elements['sysoidMask']),
                           ip_addrs: xh.xml_text_array(sd, 'ipList/ipAddr'),
                           ip_addr_masks: xh.xml_text_array(sd, 'ipList/ipAddrMask'),
                           include_groups: xh.xml_text_array(sd, 'collect/includeGroup'),
            }.compact)
          end
          systems
        end

        def self.include_collections(c)
          xh = XmlHelper.new
          include_collections = []
          c.each_element('include-collection') do |ic|
            unless ic.elements['exclude-filter'].nil?
              exclude_filters = []
              ic.each_element('exclude-filter') do |ef|
                exclude_filters.push(xh.xml_element_text(ef))
              end
            end
            include_collections.push({ data_collection_group: ic.attributes['dataCollectionGroup'], exclude_filters: exclude_filters, system_def: ic.attributes['systemDef'] }.compact)
          end
          include_collections
        end
      end

      class SnmpCollection < OpennmsCollection
        attr_reader :include_collections, :resource_types, :groups, :systems, :max_vars_per_pdu, :snmp_stor_flag
        def initialize(name:, type: 'snmp', rrd_step: nil, rras: nil, max_vars_per_pdu: nil, snmp_stor_flag: nil, include_collections: nil, resource_types: nil, groups: nil, systems: nil)
          @include_collections = include_collections || []
          @resource_types = resource_types || []
          @groups = groups || []
          @systems = systems || []
          @max_vars_per_pdu = max_vars_per_pdu
          @snmp_stor_flag = snmp_stor_flag
          super(name: name, type: type, rrd_step: rrd_step, rras: rras)
        end

        def type_config(c)
          @max_vars_per_pdu = begin
                                Integer(c.attributes['maxVarsPerPdu'])
                              rescue
                                nil
                              end
          @snmp_stor_flag = c.attributes['snmpStorageFlag']
          @include_collections = SnmpCollectionUtils.include_collections(c)
          @resource_types = SnmpCollectionUtils.resource_types(c)
          @groups = SnmpCollectionUtils.groups(c, 'groups/group')
          @systems = SnmpCollectionUtils.system_defs(c, 'systems/systemDef')
        end

        def update(rrd_step:, rras:, max_vars_per_pdu:, snmp_stor_flag:, include_collections:)
          super(rrd_step: rrd_step, rras: rras)
          @include_collections = include_collections unless include_collections.nil?
          @max_vars_per_pdu = max_vars_per_pdu unless max_vars_per_pdu.nil?
          @snmp_stor_flag = snmp_stor_flag unless snmp_stor_flag.nil?
        end

        def include_collection(data_collection_group:)
          groups = @include_collections.select { |ic| ic[:data_collection_group].eql?(data_collection_group) }
          return if groups.nil? || groups.empty?
          raise DuplicateIncludeCollection, "More than one include-collection for dataCollectionGroup named '#{data_collection_group}' found in #{@name}" unless groups.one?
          groups.pop
        end
      end

      class JdbcCollection < OpennmsCollection
        attr_reader :queries
        def initialize(name:, type: 'jdbc', rrd_step: nil, rras: nil)
          @queries = []
          super
        end

        def type_config(c)
          c.each_element('queries/query') do |query|
            columns = {}
            query.each_element('columns/column') do |column|
              columns[column.attributes['name']] = { 'type' => column.attributes['type'], 'alias' => column.attributes['alias'], 'data-source-name' => column.attributes['data-source-name'] }.compact
            end
            @queries.push(JdbcQuery.new(name: query.attributes['name'], if_type: query.attributes['ifType'], recheck_interval: Integer(query.attributes['recheckInterval']), resource_type: query.attributes['resourceType'], instance_column: query.attributes['instance-column'], query_string: xml_element_multiline_blank_text(query, 'statement/queryString'), columns: columns))
          end
        end

        def query(name:)
          query = @queries.select { |q| q.name.eql?(name) }
          return if query.nil? || query.empty?
          raise DuplicateJdbcQuery, "More than one query named #{name} found in JDBC collection #{@name}" unless query.one?
          query.pop
        end
      end

      class JdbcQuery
        attr_reader :name, :if_type, :recheck_interval, :resource_type, :instance_column, :query_string, :columns
        def initialize(name:, if_type:, recheck_interval:, query_string:, columns: {}, resource_type: nil, instance_column: nil)
          @name = name
          @if_type = if_type
          @recheck_interval = recheck_interval
          @resource_type = resource_type
          @instance_column = instance_column
          @query_string = query_string
          @columns = columns
        end

        def update(if_type:, recheck_interval:, resource_type:, query_string:, columns:, instance_column: nil)
          @if_type = if_type unless if_type.nil?
          @recheck_interval = recheck_interval unless recheck_interval.nil?
          @resource_type = resource_type unless resource_type.nil?
          @query_string = query_string unless query_string.nil?
          @columns = columns unless columns.nil?
          @instance_column = instance_column unless instance_column.nil?
        end
      end

      class JmxCollection < OpennmsCollection
        attr_reader :mbeans
        def initialize(name:, type: 'jdbc', rrd_step: nil, rras: nil)
          @mbeans = []
          super
        end

        def type_config(c)
          c.each_element('mbeans/mbean') do |mbean|
            attribs = {}
            mbean.each_element('attrib') do |attrib|
              attribs[attrib.attributes['name']] = { 'type' => attrib.attributes['type'], 'alias' => attrib.attributes['alias'], 'maxval' => attrib.attributes['maxval'], 'minval' => attrib.attributes['minval'] }.compact
            end
            comp_attribs = {}
            mbean.each_element('comp-attrib') do |ca|
              comp_attribs[ca['name']] = { 'type' => ca.attributes['type'], 'alias' => ca.attributes['alias'] }.compact
              cms = {}
              ca.each_element('comp-member') do |cm|
                cms[cm.attributes['name']] = { 'type' => cm.attributes['type'], 'alias' => cm.attributes['alias'], 'maxval' => cm.attributes['maxval'], 'minval' => cm.attributes['minval'] }.compact
              end
              comp_attribs[ca['name']]['comp_members'] = cms
            end
            @mbeans.push(JmxMBean.new(name: mbean.attributes['name'], objectname: mbean.attributes['objectname'], keyfield: mbean.attributes['keyfield'], resource_type: mbean.attributes['resource-type'], exclude: mbean.attributes['exclude'], key_alias: mbean.attributes['key-alias'], attribs: attribs, include_mbeans: xml_text_array(mbean, 'includeMbean'), comp_attribs: comp_attribs))
          end
        end

        def mbean(name:, objectname:)
          mbean = @mbeans.select { |q| q.name.eql?(name) && q.objectname.eql?(objectname) }
          return if mbean.nil? || mbean.empty?
          raise DuplicateJmxMBean, "More than one mbean named #{name} and objectname #{objectname} found in JMX collection #{@name}" unless mbean.one?
          mbean.pop
        end
      end

      class JmxMBean
        attr_reader :name, :objectname, :keyfield, :exclude, :key_alias, :resource_type, :attribs, :include_mbeans, :comp_attribs

        def initialize(name:, objectname:, keyfield: nil, exclude: nil, key_alias: nil, resource_type: nil, attribs: nil, include_mbeans: nil, comp_attribs: nil)
          @name = name
          @objectname = objectname
          @keyfield = keyfield
          @exclude = exclude
          @key_alias = key_alias
          @resource_type = resource_type
          @attribs = attribs || []
          @include_mbeans = include_mbeans || []
          @comp_attribs = comp_attribs || []
        end

        def update(keyfield: nil, exclude: nil, key_alias: nil, resource_type: nil, attribs: nil, include_mbeans: nil, comp_attribs: nil)
          @keyfield = keyfield unless keyfield.nil?
          @exclude = exclude unless exclude.nil?
          @key_alias = key_alias unless key_alias.nil?
          @resource_type = resource_type unless resource_type.nil?
          @attribs = attribs unless attribs.nil?
          @include_mbeans = include_mbeans unless include_mbeans.nil?
          @comp_attribs = comp_attribs unless comp_attribs.nil?
        end
      end

      # unlike every other type of collection, the sets of things to collect (groups, in this case) are independent of the collection
      class WsmanCollection < OpennmsCollection
        attr_reader :include_system_definitions, :include_system_definition
        def initialize(name:, type: 'wsman', rrd_step: nil, rras: nil, include_system_definitions: nil, include_system_definition: nil)
          @include_system_definition = include_system_definition || []
          @include_system_definitions = include_system_definitions
          super(name: name, type: type, rrd_step: rrd_step, rras: rras)
        end

        def type_config(c)
          @include_system_definitions = true unless c.elements['include-all-system-definitions'].nil?
          c.each_element('include-system-definition') do |isd|
            @include_system_definition.push(xml_element_text(isd))
          end
        end

        def update(rrd_step:, rras:, include_system_definitions:, include_system_definition:)
          @rrd_step = rrd_step unless rrd_step.nil?
          @rras = rras unless rras.nil?
          @include_system_definitions = include_system_definitions unless include_system_definitions.nil?
          @include_system_definition = include_system_definition unless include_system_definition.nil?
        end
      end

      class WsmanGroup
        attr_reader :name, :resource_uri, :resource_type, :dialect, :filter, :attribs
        def initialize(name:, resource_uri:, resource_type:, dialect:, filter:, attribs:)
          @name = name
          @resource_uri = resource_uri
          @resource_type = resource_type
          @dialect = dialect
          @filter = filter
          @attribs = attribs
        end

        def update(resource_uri:, resource_type:, dialect:, filter:, attribs:)
          @resource_uri = resource_uri unless resource_uri.nil?
          @resource_type = resource_type unless resource_type.nil?
          @dialect = dialect unless dialect.nil?
          @filter = filter unless filter.nil?
          @attribs = attribs unless attribs.nil?
        end
      end

      class WsmanSystemDefinition
        attr_reader :name, :rule, :include_groups
        def initialize(name:, rule:, include_groups:)
          @name = name
          @rule = rule
          @include_groups = include_groups || []
        end

        def update(rule:, include_groups:)
          @rule = rule unless rule.nil?
          @include_groups = include_groups unless include_groups.nil?
        end
      end

      class XmlCollection < OpennmsCollection
        attr_reader :sources
        def initialize(name:, type: 'xml', rrd_step: nil, rras: nil)
          @sources = []
          super
        end

        def include?(source)
          @sources.any? { |s| s.eql?(source) }
        end

        def source(url:)
          source = @sources.filter { |s| s.url.eql?(url) }
          return if source.nil? || source.empty?
          raise XmlSourceDuplicateEntry, "Duplicate xml-source entries found for url '#{url}'" unless source.one?
          source.pop
        end

        def type_config(c)
          c.each_element('xml-source') do |s|
            url = s.attributes['url']
            groups = self.class.groups_from_element(s, 'xml-group')
            import_groups = []
            s.each_element('import-groups') do |ig|
              f = xml_element_text(ig)
              if f.start_with?('xml-datacollection/')
                import_groups.push(f[19..-1])
              else
                import_groups.push(f)
              end
            end
            request = nil
            unless s.elements['request'].nil?
              request = {}
              request['method'] = s.elements['request'].attributes['method']
              rps = {}
              s.each_element('request/parameter') do |rp|
                rps[rp.attributes['name']] = rp.attributes['value']
              end
              request['parameters'] = rps
              hs = {}
              s.each_element('request/header') do |h|
                hs[h.attributes['name']] = h.attributes['value']
              end
              request['headers'] = hs
              unless s.elements['request/content'].nil?
                request['content_type'] = xml_attr_value(s, 'request/content/@type')
                request['content'] = xml_element_multiline_text(s, 'request/content')
              end
            end
            sources.push(XmlSource.new(url: url, groups: groups, import_groups: import_groups, request: request))
          end
        end

        def self.groups_from_element(element, xpath)
          return if element.nil? || !element.is_a?(REXML::Element) || element.elements[xpath].nil?
          groups = []
          element.each_element(xpath) do |g|
            rk = [] unless g.elements['resource-key'].nil?
            g.each_element('resource-key/key-xpath') do |k|
              rk.push k.texts.collect(&:value).join('').strip
            end
            xml_objects = []
            g.each_element('xml-object') do |o|
              xml_objects.push({ 'name' => o.attributes['name'], 'type' => o.attributes['type'], 'xpath' => o.attributes['xpath'] })
            end
            xmlgroup = { 'name' => g.attributes['name'], 'resource_type' => g.attributes['resource-type'], 'resource_xpath' => g.attributes['resource-xpath'] }
            xmlgroup['resource_keys'] = rk unless rk.nil?
            xmlgroup['objects'] = xml_objects unless xml_objects.nil?
            xmlgroup['key_xpath'] = g.attributes['key-xpath'] unless g.attributes['key-xpath'].nil?
            xmlgroup['timestamp_xpath'] = g.attributes['timestamp-xpath'] unless g.attributes['timestamp-xpath'].nil?
            xmlgroup['timestamp_format'] = g.attributes['timestamp-format'] unless g.attributes['timestamp-format'].nil?
            groups.push xmlgroup
          end
          groups
        end
      end

      class XmlSource
        attr_reader :url, :groups, :import_groups, :request

        def initialize(url:, groups:, import_groups:, request: nil)
          @url = url
          @groups = groups || []
          @import_groups = import_groups || []
          @request = request
        end

        def to_s
          "url='#{@url}'\n" \
            "groups='#{@groups.collect(&:to_s).join(', ')}'\n" \
            "import_groups='#{@import_groups.collect(&:to_s).join(', ')}'\n" \
            "request='#{@request}'"
        end

        def eql?(s)
          self.class.eql?(s.class) && @url.eql?(s.url) && @groups.eql?(s.groups) && @import_groups.eql?(s.import_groups) && @request.eql?(s.request)
        end

        def match?(s)
          @url.eql?(s.url)
        end

        def group(name:)
          gn = @groups.filter { |g| g['name'].eql?(name) }
          return if gn.nil? || gn.empty?
          raise DuplicateXmlGroup, "More than one group named #{name} found in file" unless gn.one?
          gn.pop
        end

        def update(request_method:, request_headers:, request_params:, request_content:, request_content_type:, import_groups:, groups:)
          @request = self.class.request_from_properties(request_method: request_method, request_params: request_params, request_headers: request_headers, request_content: request_content, request_content_type: request_content_type)
          if false.eql?(import_groups)
            @import_groups = []
          elsif !import_groups.empty?
            @import_groups = import_groups
          end
          if false.eql?(groups)
            @groups = []
          elsif !groups.empty?
            @groups = groups
          end
        end

        def self.request_from_properties(request_method:, request_params:, request_headers:, request_content:, request_content_type:)
          r = nil
          if !request_method.nil? || (!request_params.nil? && !request_params.empty?) || (!request_headers.nil? && !request_headers.empty?) || !request_content.nil? || !request_content_type.nil?
            r = {}
            r['method'] = request_method unless request_method.nil?
            unless request_params.nil? || request_params.empty?
              r['parameters'] = {}
              request_params.each do |k, v|
                r['parameters'][k] = v
              end
            end
            unless request_headers.nil? || request_headers.empty?
              r['headers'] = {}
              request_headers.each do |k, v|
                r['headers'][k] = v
              end
            end
            r['content'] = request_content unless request_content.nil?
            r['content_type'] = request_content_type unless request_content_type.nil?
          end
          r
        end

        def self.create(url:, import_groups:, groups:, request_method:, request_params:, request_headers:, request_content:, request_content_type:)
          XmlSource.new(url: url, groups: groups, import_groups: import_groups, request: request_from_properties(request_method: request_method, request_params: request_params, request_headers: request_headers, request_content: request_content, request_content_type: request_content_type))
        end
      end

      class XmlSourceDuplicateEntry < StandardError; end

      class XmlCollectionDoesNotExist < StandardError; end

      class XmlSourceDoesNotExist < StandardError; end

      class DuplicateXmlGroup < StandardError; end

      class DuplicateIncludeCollection < StandardError; end

      class NoSuchCollection < StandardError; end

      class DuplicateJdbcQuery < StandardError; end

      class DuplicateJmxMBean < StandardError; end

      class DuplicateWsmanGroup < StandardError; end

      class DuplicatedSystemDefinition < StandardError; end

      class DuplicateResourceType < StandardError; end

      class DuplicateSnmpGroup < StandardError; end

      class NoSuchWsmanCollectionFile < StandardError; end
    end
  end
end

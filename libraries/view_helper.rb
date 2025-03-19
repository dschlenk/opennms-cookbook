module Opennms
  module Cookbook
    module View
      module WallboardTemplate
        def wallboard_resource_init
          wallboard_resource_create unless wallboard_resource_exist?
        end

        def wallboard_resource
          return unless wallboard_resource_exist?
          find_resource!(:template, "#{onms_etc}/dashboard-config.xml")
        end

        def ro_wallboard_resource_init
          ro_wallboard_resource_create unless ro_wallboard_resource_exist?
        end

        def ro_wallboard_resource
          return unless ro_wallboard_resource_exist?
          find_resource!(:template, "RO #{onms_etc}/dashboard-config.xml")
        end

        private

        def wallboard_resource_exist?
          !find_resource(:template, "#{onms_etc}/dashboard-config.xml").nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def wallboard_resource_create
          file = Opennms::Cookbook::View::DashboardConfig.new
          file.read!("#{onms_etc}/dashboard-config.xml")
          with_run_context(:root) do
            declare_resource(:template, "#{onms_etc}/dashboard-config.xml") do
              cookbook 'opennms'
              source 'dashboard-config.xml.erb'
              owner node['opennms']['username']
              group node['opennms']['groupname']
              mode '0664'
              variables(config: file)
              action :nothing
              delayed_action :create
              notifies :restart, 'service[opennms]'
            end
          end
        end

        def ro_wallboard_resource_exist?
          !find_resource(:template, "RO #{onms_etc}/dashboard-config.xml").nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def ro_wallboard_resource_create
          file = Opennms::Cookbook::View::DashboardConfig.new
          file.read!("#{onms_etc}/dashboard-config.xml")
          with_run_context(:root) do
            declare_resource(:template, "RO #{onms_etc}/dashboard-config.xml") do
              path "#{Chef::Config[:file_cache_path]}/dashboard-config.xml"
              cookbook 'opennms'
              source 'dashboard-config.xml.erb'
              owner node['opennms']['username']
              group node['opennms']['groupname']
              mode '0664'
              variables(config: file)
              action :nothing
              delayed_action :nothing
            end
          end
        end
      end

      module SurveillanceTemplate
        def view_resource_init
          view_resource_create unless view_resource_exist?
        end

        def view_resource
          return unless view_resource_exist?
          find_resource!(:template, "#{onms_etc}/surveillance-views.xml")
        end

        def ro_view_resource_init
          ro_view_resource_create unless ro_view_resource_exist?
        end

        def ro_view_resource
          return unless ro_view_resource_exist?
          find_resource!(:template, "RO #{onms_etc}/surveillance-views.xml")
        end

        private

        def view_resource_exist?
          !find_resource(:template, "#{onms_etc}/surveillance-views.xml").nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def view_resource_create
          file = Opennms::Cookbook::View::SurveillanceConfig.new
          file.read!("#{onms_etc}/surveillance-views.xml")
          with_run_context(:root) do
            declare_resource(:template, "#{onms_etc}/surveillance-views.xml") do
              cookbook 'opennms'
              source 'surveillance-views.xml.erb'
              owner node['opennms']['username']
              group node['opennms']['groupname']
              mode '0664'
              variables(config: file)
              action :nothing
              delayed_action :create
            end
          end
        end

        def ro_view_resource_exist?
          !find_resource(:template, "RO #{onms_etc}/surveillance-views.xml").nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def ro_view_resource_create
          file = Opennms::Cookbook::View::SurveillanceConfig.new
          file.read!("#{onms_etc}/surveillance-views.xml")
          with_run_context(:root) do
            declare_resource(:template, "RO #{onms_etc}/surveillance-views.xml") do
              path "#{Chef::Config[:file_cache_path]}/surveillance-views.xml"
              cookbook 'opennms'
              source 'surveillance-views.xml.erb'
              owner node['opennms']['username']
              group node['opennms']['groupname']
              mode '0664'
              variables(config: file)
              action :nothing
              delayed_action :nothing
            end
          end
        end
      end

      class SurveillanceConfig
        include Opennms::XmlHelper
        attr_reader :views
        attr_accessor :default_view

        def initialize
          @views = {}
        end

        def read!(file = 'surveillance-views.xml')
          raise ArgumentError, "File #{file} does not exist" unless ::File.exist?(file)
          doc = xmldoc_from_file(file)
          @default_view = doc.elements['/surveillance-view-configuration'].attributes['default-view'] unless doc.elements['surveillance-view-configuration'].attributes['default-view'].nil?
          doc.each_element('/surveillance-view-configuration/views/view') do |v|
            view = {}
            view['name'] = v.attributes['name']
            view['refresh-seconds'] = v.attributes['refresh-seconds']
            rows = {}
            v.each_element('rows/row-def') do |r|
              rows[r.attributes['label']] = []
              r.each_element('category') do |c|
                rows[r.attributes['label']].push(c.attributes['name'])
              end
            end
            view['rows'] = rows
            columns = {}
            v.each_element('columns/column-def') do |c|
              columns[c.attributes['label']] = []
              c.each_element('category') do |cat|
                columns[c.attributes['label']].push(cat.attributes['name'])
              end
            end
            view['columns'] = columns
            @views[view['name']] = view.compact
          end
        end

        def self.read(file = 'surveillance-views.xml')
          sc = SurveillanceConfig.new
          sc.read!(file)
          sc
        end
      end

      class DashboardConfig
        include Opennms::XmlHelper
        attr_reader :wallboards
        attr_accessor :default_wallboard
        def initialize
          @wallboards = []
        end

        def read!(file = 'dashboard-config.xml')
          doc = xmldoc_from_file(file) || REXML::Document.new('<wallboards/>')
          doc.each_element('/wallboards/wallboard') do |w|
            wallboard = {}
            wallboard['title'] = w.attributes['title']
            @default_wallboard = w.attributes['title'] if xml_element_text(w, 'default').eql?('true')
            dashlets = [] unless w.elements['dashlets/dashlet'].nil?
            w.each_element('dashlets/dashlet') do |d|
              dashlet = {}
              dashlet['title'] = xml_element_text(d, 'title')
              dashlet['boost_duration'] = xml_element_text(d, 'boostDuration').to_i
              dashlet['boost_priority'] = xml_element_text(d, 'boostPriority').to_i
              dashlet['dashlet_name'] = xml_element_text(d, 'dashletName')
              dashlet['duration'] = xml_element_text(d, 'duration').to_i
              dashlet['parameters'] = {} unless d.elements['parameters'].nil?
              d.elements['parameters'].each_element('entry') do |p|
                dashlet['parameters'][xml_element_text(p, 'key')] = xml_element_text(p, 'value')
              end unless d.elements['parameters'].nil?
              dashlet['priority'] = xml_element_text(d, 'priority').to_i
              dashlets.push(dashlet.compact)
            end
            wallboard['dashlets'] = dashlets
            @wallboards.push(wallboard.compact)
          end
        end

        def wallboard(title:)
          wallboard = @wallboards.select { |w| w['title'].eql?(title) }
          return if wallboard.empty?
          raise DuplicateWallboards, "More than one wallboard with title #{title} found." unless wallboard.one?
          wallboard.pop
        end

        def dashlet(wallboard:, title:)
          raise ArgumentError, 'Wallboard must be a hash' unless wallboard.is_a?(Hash)
          return if wallboard['dashlets'].nil?
          dashlet = wallboard['dashlets'].select { |d| d['title'].eql?(title) }
          return if dashlet.empty?
          raise DuplicateDashlets, "More than one dashlet in wallboard #{wallboard['title']} with title #{title}" unless dashlet.one?
          dashlet.pop
        end

        def self.read(file = 'dashboard-config.xml')
          dc = DashboardConfig.new
          dc.read!(file)
          dc
        end
      end

      class DuplicateWallboards < StandardError; end
      class DuplicateDashlets < StandardError; end
    end
  end
end

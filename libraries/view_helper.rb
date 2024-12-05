module Opennms
  module Cookbook
    module View
      module SurveillanceTemplate
        def view_resource_init
          view_resource_create unless view_resource_exist?
        end

        def view_resource
          return unless view_resource_exist?
          find_resource!(:template, "#{onms_etc}/surveillance-views.xml")
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
            Chef::Log.info("found view #{v.attributes['name']}: #{v}")
            view = {}
            view['name'] = v.attributes['name']
            view['refresh-seconds'] = v.attributes['refresh-seconds']
            rows = {}
            v.each_element('rows/row-def') do |r|
              Chef::Log.info("adding row #{r.attributes['label']}")
              rows[r.attributes['label']] = []
              r.each_element('category') do |c|
                Chef::Log.info("adding category #{c} to row #{r.attributes['label']}")
                rows[r.attributes['label']].push(c.attributes['name'])
              end
            end
            view['rows'] = rows
            columns = {}
            v.each_element('columns/column-def') do |c|
              Chef::Log.info("adding column #{c.attributes['label']}")
              columns[c.attributes['label']] = []
              c.each_element('category') do |cat|
                Chef::Log.info("adding category #{cat} to column #{c.attributes['label']}")
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
    end
  end
end

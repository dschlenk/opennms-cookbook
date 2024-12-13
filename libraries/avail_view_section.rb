module Opennms
  module Cookbook
    module Rtc
      module AvailViewSection
        require_relative 'xml_helper'
        include Opennms::XmlHelper
        def vd_resource_init
          vd_resource_create unless vd_resource_exist?
        end

        def vd_resource
          return unless vd_resource_exist?
          find_resource!(:template, "#{onms_etc}/viewsdisplay.xml")
        end

        private

        def vd_resource_exist?
          !find_resource(:template, "#{onms_etc}/viewsdisplay.xml").nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def vd_resource_create
          vd = Opennms::Cookbook::Rtc::ViewsDisplay.new
          vd.read!("#{onms_etc}/viewsdisplay.xml") if ::File.exist?("#{onms_etc}/viewsdisplay.xml")
          with_run_context(:root) do
            declare_resource(:template, "#{onms_etc}/viewsdisplay.xml") do
              cookbook 'opennms'
              source 'viewsdisplay.xml.erb'
              owner node['opennms']['username']
              group node['opennms']['groupname']
              mode '0664'
              variables(views: vd.views)
              action :nothing
              delayed_action :create
              notifies :restart, 'service[opennms]'
            end
          end
        end
      end

      class ViewsDisplay
        include Opennms::XmlHelper
        attr_reader :views
        def initialize
          @views = {}
        end

        def read!(file = 'viewsdisplay.xml')
          raise ArgumentError, "File #{file} not found" unless ::File.exist?(file)
          xmldoc_from_file(file).each_element('/viewinfo/view') do |view|
            view_name = xml_element_text(view, 'view-name')
            sections = [] unless view.elements['section'].nil?
            view.each_element('section') do |section|
              s = { 'name' => xml_element_text(section, 'section-name') }
              s['categories'] = xml_text_array(section, 'category')
              sections.push(s)
            end
            @views[view_name] = View.new(name: view_name, sections: sections)
          end
        end

        def self.read(file = 'viewsdisplay.xml')
          vd = ViewsDisplay.new
          vd.read!(file)
          vd
        end
      end

      class View
        attr_reader :name, :sections
        def initialize(name:, sections: [])
          @name = name
          @sections = sections
        end

        def section(section:)
          sec = @sections.select { |s| s['name'].eql?(section) }
          return if sec.empty?
          raise DuplicateViewSection, "More than one section named #{section} found in view #{@name}." unless sec.one?
          sec.pop
        end

        def add_section(section:, categories:, before:, after:, position:)
          index = -1
          if !before.nil?
            index = @sections.bsearch_index { |s| s['name'].eql?(before) }
          elsif !after.nil?
            index = @sections.bsearch_index { |s| s['name'].eql?(after) }
            index += 1 unless index.nil?
          end
          if index.nil? || index < 0
            if 'top'.eql?(position)
              @sections.unshift({ 'name' => section, 'categories' => categories })
            else
              @sections.push({ 'name' => section, 'categories' => categories })
            end
          else
            @sections.insert(index, { 'name' => section, 'categories' => categories })
          end
        end

        def delete_section(section:)
          @sections.delete_if { |s| s['name'].eql?(section) }
        end
      end

      class DuplicateViewSection < StandardError; end
    end
  end
end

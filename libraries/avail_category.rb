module Opennms
  module Cookbook
    module ConfigHelpers
      module AvailCategory
        module AvailCategoryTemplate
          require_relative 'xml_helper'
          include Opennms::XmlHelper
          def ac_resource_init
            ac_resource_create unless ac_resource_exist?
          end

          def ac_resource
            return unless ac_resource_exist?
            find_resource!(:template, "#{onms_etc}/categories.xml")
          end

          def ro_ac_resource_init
            ro_ac_resource_create unless ro_ac_resource_exist?
          end

          def ro_ac_resource
            return unless ro_ac_resource_exist?
            find_resource!(:template, "RO #{onms_etc}/categories.xml")
          end

          private

          def ac_resource_exist?
            !find_resource(:template, "#{onms_etc}/categories.xml").nil?
          rescue Chef::Exceptions::ResourceNotFound
            false
          end

          def ac_resource_create
            ac = Opennms::Cookbook::ConfigHelpers::AvailCategory::AvailCategoryFile.new
            ac.read!("#{onms_etc}/categories.xml") if ::File.exist?("#{onms_etc}/categories.xml")
            with_run_context :root do
              declare_resource(:template, "#{onms_etc}/categories.xml") do
                source 'categories.xml.erb'
                cookbook 'opennms'
                owner node['opennms']['username']
                group node['opennms']['groupname']
                mode '0664'
                variables(category_groups: ac)
                action :nothing
                delayed_action :create
              end
            end
          end

          def ro_ac_resource_exist?
            !find_resource(:template, "RO #{onms_etc}/categories.xml").nil?
          rescue Chef::Exceptions::ResourceNotFound
            false
          end

          def ro_ac_resource_create
            ac = Opennms::Cookbook::ConfigHelpers::AvailCategory::AvailCategoryFile.new
            ac.read!("#{onms_etc}/categories.xml") if ::File.exist?("#{onms_etc}/categories.xml")
            with_run_context :root do
              declare_resource(:template, "RO #{onms_etc}/categories.xml") do
                path "#{Chef::Config[:file_cache_path]}/categories.xml"
                source 'categories.xml.erb'
                cookbook 'opennms'
                owner node['opennms']['username']
                group node['opennms']['groupname']
                mode '0664'
                variables(category_groups: ac)
                action :nothing
                delayed_action :nothing
              end
            end
          end
        end

        class CategoryGroup
          attr_reader :name, :comment, :common_rule, :categories

          def initialize(name:, comment: nil, common_rule:, categories:)
            @name = name
            @comment = comment
            @common_rule = common_rule
            @categories = categories
          end

          def to_s
            "name = #{name}\n" \
            "comment = #{comment}\n" \
            "common_rule = #{common_rule}\n" \
            "categories = #{categories}\n"
          end

          def eql?(cg)
            return unless self.class.eql?(cg.class)
            return true if @name.eql?(cg.name) &&
                           @comment.eql?(cg.comment) &&
                           @common_rule.eql?(cg.common_rule) &&
                           @categories.eql?(cg.categories)
            false
          end

          def match?(cg)
            match_by_name(cg.name)
          end

          def match_by_name?(name)
            return true if @name.eql?(name)
          end

          def category(label)
            c = @categories.filter { |cc| cc.match_by_label?(label) }
            return if c.nil? || c.empty?
            raise AvailCategoryGroupDuplicateEntry, "Duplicate category found with label #{label} in group #{@name}" unless c.one?
            c.pop
          end

          def add(category)
            @categories.push category
          end

          def remove(category)
            @categories.reject! { |c| c.match?(category) }
          end

          def update(comment: nil, common_rule: nil, categories: nil)
            @comment = comment unless comment.nil?
            @common_rule = common_rule unless common_rule.nil?
            @categories = categories unless categories.nil?
          end
        end

        class AvailCategoryFile
          include Opennms::XmlHelper
          attr_reader :category_groups

          def initialize
            @category_groups = []
          end

          def read!(file = 'categories.xml')
            raise ArgumentError, "File #{file} does not exist" unless ::File.exist?(file)
            xmldoc_from_file(file).each_element('/catinfo/categorygroup') do |cg|
              groupname = xml_element_text(cg, 'name')
              groupcomment = xml_element_text(cg, 'comment')
              grouprule = xml_element_text(cg, 'common/rule')
              cats = []
              cg.each_element('categories/category') do |c| # schema requires at least one category
                catlabel = xml_element_text(c, 'label')
                catcomment = xml_element_text(c, 'comment')
                catnormal = begin
                              Integer(xml_element_text(c, 'normal'))
                            rescue
                              xml_element_text(c, 'normal').to_f
                            end
                catwarning = begin
                               Integer(xml_element_text(c, 'warning'))
                             rescue
                               xml_element_text(c, 'warning').to_f
                             end
                catrule = xml_element_text(c, 'rule')
                catsvcs = xml_text_array(c, 'service')
                cats.push Category.new(label: catlabel, comment: catcomment, normal: catnormal, warning: catwarning, rule: catrule, services: catsvcs || [])
              end
              @category_groups.push(CategoryGroup.new(name: groupname, comment: groupcomment, common_rule: grouprule, categories: cats))
            end
          end

          def category_group(name)
            cgs = @category_groups.filter { |cg| cg.match_by_name?(name) }
            return if cgs.nil? || cgs.empty?
            raise CategoryGroupDuplicateEntry, "Duplicate category group named #{group}" unless cgs.one?
            cgs.pop
          end

          def category(group, label)
            cg = category_group(group)
            cg.category(label) unless cg.nil?
          end

          def delete(group, label)
            cg = category_group(group)
            c = category(group, label)
            cg.remove(c) if !cg.nil? && !c.nil?
          end

          def to_s
            "groups: #{category_groups.collect(&:to_s).join("\n")}"
          end

          def self.read(file = 'categories.xml')
            ac = new
            ac.read!(file)
            ac
          end
        end

        class Category
          attr_reader :label, :comment, :normal, :warning, :rule, :services

          def initialize(label:, comment: nil, normal:, warning:, rule:, services: nil)
            @label = label
            @comment = comment
            @normal = normal
            @warning = warning
            @rule = rule
            @services = services
          end

          def match?(c)
            match_by_label?(c.label)
          end

          def match_by_label?(label)
            return true if @label.eql?(label)
            false
          end

          def eql?(c)
            return false unless self.class.eql?(c.class)
            return true if @label.eql?(c.label) &&
                           @comment.eql?(c.comment) &&
                           @normal.eql?(c.normal) &&
                           @warning.eql?(c.warning) &&
                           @rule.eql?(c.rule) &&
                           @services.eql?(c.services)
            false
          end

          def to_s
            "label = #{@label}\n" \
              "comment #{@comment}\n" \
              "normal = #{@normal}\n" \
              "warning = #{@warning}\n" \
              "rule = #{@rule}\n" \
              "services = #{@services.join(', ')}\n"
          end

          def update(comment: nil, normal: nil, warning: nil, rule: nil, services: nil)
            @comment = comment unless comment.nil?
            @normal = normal unless normal.nil?
            @warning = warning unless warning.nil?
            @rule = rule unless rule.nil?
            @services = services unless services.nil?
          end
        end

        class AvailCategoryGroupDuplicateEntry < StandardError; end

        class CategoryGroupDuplicateEntry < StandardError; end

        class CategoryGroupNotFound < StandardError; end

        class NoServices < StandardError; end
      end
    end
  end
end

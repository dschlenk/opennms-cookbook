module Opennms
  module Cookbook
    module Threshold
      module ThresholdsTemplate
        def thresholds_resource_init
          thresholds_resource_create unless thresholds_resource_exist?
        end

        def thresholds_resource
          return unless thresholds_resource_exist?
          find_resource!(:template, "#{onms_etc}/thresholds.xml")
        end

        def ro_thresholds_resource_init
          ro_thresholds_resource_create unless ro_thresholds_resource_exist?
        end

        def ro_thresholds_resource
          return unless ro_thresholds_resource_exist?
          find_resource!(:template, "RO #{onms_etc}/thresholds.xml")
        end

        private

        def thresholds_resource_exist?
          !find_resource(:template, "#{onms_etc}/thresholds.xml").nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def thresholds_resource_create
          file = Opennms::Cookbook::Threshold::ThresholdsFile.read("#{onms_etc}/thresholds.xml")
          with_run_context(:root) do
            declare_resource(:template, "#{onms_etc}/thresholds.xml") do
              cookbook 'opennms'
              source 'thresholds.xml.erb'
              owner node['opennms']['username']
              group node['opennms']['groupname']
              mode '0664'
              variables(config: file)
              action :nothing
              delayed_action :create
              notifies :run, 'opennms_send_event[restart_Thresholds]'
            end
          end
        end

        def ro_thresholds_resource_exist?
          !find_resource(:template, "RO #{onms_etc}/thresholds.xml").nil?
        rescue Chef::Exceptions::ResourceNotFound
          false
        end

        def ro_thresholds_resource_create
          file = Opennms::Cookbook::Threshold::ThresholdsFile.read("#{onms_etc}/thresholds.xml")
          with_run_context(:root) do
            declare_resource(:template, "RO #{onms_etc}/thresholds.xml") do
              path "#{Chef::Config[:file_cache_path]}/thresholds.xml"
              cookbook 'opennms'
              source 'thresholds.xml.erb'
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

      class ThresholdsFile
        include Opennms::XmlHelper

        attr_reader :groups

        def initialize
          @groups = {}
        end

        def read!(file = 'thresholds.xml')
          raise ArgumentError, "File #{file} does not exist" unless ::File.exist?(file)
          doc = xmldoc_from_file(file)
          doc.each_element('thresholding-config/group') do |g|
            group = ThresholdGroup.new(name: g.attributes['name'], rrd_repository: g.attributes['rrdRepository'])
            %w(threshold expression).each do |xpath|
              g.each_element(xpath) do |t|
                group.send("#{xpath}s").push(BaseThreshold.create(t))
              end
            end
            @groups[group.name] = group
          end
        end

        def self.read(file)
          tf = ThresholdsFile.new
          tf.read!(file)
          tf
        end
      end

      class ThresholdGroup
        attr_reader :name, :thresholds, :expressions
        attr_accessor :rrd_repository

        def initialize(name:, rrd_repository:)
          @name = name
          @rrd_repository = rrd_repository
          @thresholds = []
          @expressions = []
        end

        def find_rule(type:, ds_type:, filter_operator: nil, resource_filters: nil, ds_name: nil, expression: nil, triggered_uei: nil, rearmed_uei: nil)
          raise Chef::Exceptions::Validation, 'Either `ds_name` or `expression` properties must be present in a threshold rule' if ds_name.nil? && expression.nil?
          if ds_name.nil?
            expression = @expressions.select do |e|
              e.type.eql?(type) &&
                e.ds_type.eql?(ds_type) &&
                (e.filter_operator.eql?(filter_operator) || (e.filter_operator.nil? && (filter_operator.eql?('or') || filter_operator.eql?('OR'))) || (filter_operator.nil? && (e.filter_operator.eql?('or') || e.filter_operator.eql?('OR')))) &&
                e.expression.eql?(expression) &&
                e.triggered_uei.eql?(triggered_uei) &&
                e.rearmed_uei.eql?(rearmed_uei)
            end
            return if expression.empty?
            raise DuplicateThresholdRule, "More than one expression rule found with identical identity (type #{type}, ds_type #{ds_type}, filter_operator #{filter_operator}, resource_filters #{resource_filters}, expression #{expression} triggered_uei #{triggered_uei}, rearmed_uei #{rearmed_uei}) found" unless expression.one?
            expression.pop
          else
            threshold = @thresholds.select do |e|
              e.type.eql?(type) &&
                e.ds_type.eql?(ds_type) &&
                (e.filter_operator.eql?(filter_operator) || (e.filter_operator.nil? && (filter_operator.eql?('or') || filter_operator.eql?('OR'))) || (filter_operator.nil? && (e.filter_operator.eql?('or') || e.filter_operator.eql?('OR')))) &&
                e.ds_name.eql?(ds_name) &&
                e.triggered_uei.eql?(triggered_uei) &&
                e.rearmed_uei.eql?(rearmed_uei)
            end
            return if threshold.empty?
            raise DuplicateThresholdRule, "More than one threshold rule found with identical identity (type #{type}, ds_type #{ds_type}, filter_operator #{filter_operator}, resource_filters #{resource_filters}, ds_name #{ds_name}, triggered_uei #{triggered_uei}, rearmed_uei #{rearmed_uei}) found" unless threshold.one?
            threshold.pop
          end
        end

        # def add_rule(type:, ds_type:, description:, value:, rearm:, trigger: 1, ds_label: nil, triggered_uei: nil, rearmed_uei: nil, relaxed: nil, filter_operator: nil, resource_filters: nil, ds_name: nil, expression: nil)
        def add_rule(**properties)
          raise Chef::Exceptions::Validation, 'Either `ds_name` or `expression` properties must be present in a threshold rule' if !properties[:ds_name] && !properties[:expression]
          if properties[:ds_name]
            @thresholds.push(Threshold.new(**properties))
          else
            @expressions.push(Expression.new(**properties))
          end
        end

        def delete_rule(type:, ds_type:, filter_operator: nil, resource_filters: nil, ds_name: nil, expression: nil, triggered_uei: nil, rearmed_uei: nil)
          raise Chef::Exceptions::Validation, 'Either `ds_name` or `expression` properties must be present in a threshold rule' if ds_name.nil? && expression.nil?
          if !ds_name.nil?
            @thresholds.delete_if do |t|
              t.type.eql?(type) &&
                t.ds_type.eql?(ds_type) &&
                (
                  t.filter_operator.eql?(filter_operator) ||
                  (t.filter_operator.nil? && filter_operator.downcase.eql?('or')) ||
                  (filter_operator.nil? && t.filter_operator.downcase.eql?('or'))
                ) &&
                t.resource_filters.eql?(resource_filters) &&
                t.ds_name.eql?(ds_name) &&
                t.triggered_uei.eql?(triggered_uei) &&
                t.rearmed_uei.eql?(rearmed_uei)
            end
          else
            @expressions.delete_if do |e|
              e.type.eql?(type) &&
                e.ds_type.eql?(ds_type) &&
                (
                  e.filter_operator.eql?(filter_operator) ||
                  (e.filter_operator.nil? && filter_operator.downcase.eql?('or')) ||
                  (filter_operator.nil? && e.filter_operator.downcase.eql?('or'))
                ) &&
                e.resource_filters.eql?(resource_filters) &&
                e.expression.eql?(expression) &&
                e.triggered_uei.eql?(triggered_uei) &&
                e.rearmed_uei.eql?(rearmed_uei)
            end
          end
        end
      end

      class BaseThreshold
        include Opennms::XmlHelper
        attr_reader :relaxed, :description, :type, :ds_type, :value, :rearm, :trigger, :ds_label, :triggered_uei, :rearmed_uei, :filter_operator, :resource_filters

        def initialize(type:, ds_type:, value:, rearm:, trigger:, relaxed: nil, description: nil, ds_label: nil, triggered_uei: nil, rearmed_uei: nil, filter_operator: nil, resource_filters: nil)
          @relaxed = relaxed
          @description = description
          @type = type
          @ds_type = ds_type
          @value = value
          @rearm = rearm
          @trigger = trigger
          @ds_label = ds_label
          @triggered_uei = triggered_uei
          @rearmed_uei = rearmed_uei
          @filter_operator = filter_operator
          @resource_filters = resource_filters
        end

        def self.create(t)
          filters = [] unless t.elements['resource-filter'].nil?
          t.each_element('resource-filter') do |rf|
            filters.push({ 'field' => rf.attributes['field'], 'filter' => rf.texts.collect(&:value).join('').strip })
          end
          properties = { expression: t.attributes['expression'], ds_name: t.attributes['ds-name'], description: t.attributes['description'], type: t.attributes['type'], ds_type: t.attributes['ds-type'], value: t.attributes['value'].to_f, rearm: t.attributes['rearm'].to_f, trigger: t.attributes['trigger'].to_i, ds_label: t.attributes['ds-label'], triggered_uei: t.attributes['triggeredUEI'], rearmed_uei: t.attributes['rearmedUEI'], filter_operator: t.attributes['filterOperator'], resource_filters: filters }.compact
          if properties.key?(:ds_name)
            Threshold.new(**properties)
          else
            Expression.new(**properties)
          end
        end

        def update(relaxed: nil, description: nil, ds_label: nil, value: nil, rearm: nil, trigger: nil)
          @relaxed = relaxed unless relaxed.nil?
          @description = description unless description.nil?
          @ds_label = ds_label unless ds_label.nil?
          @value = value unless value.nil?
          @rearm = rearm unless rearm.nil?
          @trigger = trigger unless trigger.nil?
        end

        def to_s
          "(type: #{@type}, ds_type: #{@ds_type}, value: #{@value}, rearm: #{@rearm}, trigger: #{@trigger}, relaxed: #{@relaxed}, description: #{@description}, ds_label: #{@ds_label}, triggered_uei: #{@triggered_uei}, rearmed_uei: #{@rearmed_uei}, filter_operator: #{@filter_operator}, resource_filters: #{@resource_filters}"
        end
      end

      class Threshold < BaseThreshold
        attr_reader :ds_name

        def initialize(ds_name:, type:, ds_type:, value:, rearm:, trigger:, relaxed: nil, description: nil, ds_label: nil, triggered_uei: nil, rearmed_uei: nil, filter_operator: nil, resource_filters: nil)
          super(type: type, ds_type: ds_type, value: value, rearm: rearm, trigger: trigger, relaxed: relaxed, description: description, ds_label: ds_label, triggered_uei: triggered_uei, rearmed_uei: rearmed_uei, filter_operator: filter_operator, resource_filters: resource_filters)
          @ds_name = ds_name
        end

        def to_s
          "#{super.to_s}, ds_name: #{@ds_name}"
        end
      end

      class Expression < BaseThreshold
        attr_reader :expression

        def initialize(expression:, type:, ds_type:, value:, rearm:, trigger:, relaxed: nil, description: nil, ds_label: nil, triggered_uei: nil, rearmed_uei: nil, filter_operator: nil, resource_filters: nil)
          super(type: type, ds_type: ds_type, value: value, rearm: rearm, trigger: trigger, relaxed: relaxed, description: description, ds_label: ds_label, triggered_uei: triggered_uei, rearmed_uei: rearmed_uei, filter_operator: filter_operator, resource_filters: resource_filters)
          @expression = expression
        end

        def to_s
          "#{super.to_s}, expression: #{@expression}"
        end
      end

      class ResourceFilter
        attr_reader :field, :filter

        def initialize(field:, filter:)
          @field = field
          @filter = filter
        end

        def to_s
          "field: #{@field}, filter: #{@filter}"
        end
      end

      class DuplicateThresholdRule < StandardError; end
    end
  end
end

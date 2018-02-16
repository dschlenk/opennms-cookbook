# frozen_string_literal: true
require 'rexml/document'
class Expression < Inspec.resource(1)
  name 'expression'

  desc '
    OpenNMS expression
  '

  example('
    describe expression(\'group\', \'expression\', \'ds-type\', \'type\', \'filter-operator\' = ') || ', resource_filters = nil) do
      it { should exist }
      its(\'relaxed\') { should be true }
      its(\'description\') { should eq \'the description\' }
      its(\'value\') { should eq 1.0 }
      its(\'rearm\') { should eq 0.9 }
      its(\'trigger\') { should eq 1 }
      its(\'ds_label\') { should eq \'ds-label\' }
      its(\'triggered_uei]\') { should eq \'uei.opennms.org/triggeredUEI\' }
      its(\'rearmed_uei\') { should eq \'uei.opennms.org/rearmedUEI\' }
    end
  '

  # rubocop:disable Metrics/ParameterLists
  def initialize(group, expression, ds_type, type, filter_operator = 'or', resource_filters = nil)
    # rubocop:enable Metrics/ParameterLists
    @group = group
    @expression = expression
    @ds_type = ds_type
    @type = type
    @filter_operator = filter_operator
    @resource_filters = resource_filters
    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/thresholds.xml').content)
    ex_el = expression_el(doc) unless doc.nil?
    @exists = !ex_el.nil?
    if @exists
      @params = {}
      @params[:relaxed] = false
      @params[:relaxed] = true if ex_el.attributes['relaxed'] == 'true'
      @params[:description] = ex_el.attributes['description'] unless ex_el.attributes['description'].nil?
      @params[:value] = ex_el.attributes['value'].to_f unless ex_el.attributes['value'].nil?
      @params[:rearm] = ex_el.attributes['rearm'].to_f unless ex_el.attributes['rearm'].nil?
      @params[:trigger] = ex_el.attributes['trigger'].to_i unless ex_el.attributes['trigger'].nil?
      @params[:ds_label] = ex_el.attributes['ds-label'] unless ex_el.attributes['ds-label'].nil?
      @params[:triggered_uei] = ex_el.attributes['triggeredUEI'] unless ex_el.attributes['triggeredUEI'].nil?
      @params[:rearmed_uei] = ex_el.attributes['rearmedUEI'] unless ex_el.attributes['rearmedUEI'].nil?
    end
  end

  def exist?
    @exists
  end

  def method_missing(name)
    @params[name]
  end

  private

  def expression_el(doc)
    attrs = "/thresholding-config/group[@name = '#{@group}']/expression[@expression = '#{@expression}' and @ds-type = '#{@ds_type}' and @type = '#{@type}'"
    attrs = "#{attrs} and @filterOperator = '#{@filter_operator}'" unless @filter_operator.nil? || @filter_operator == 'or'
    if @resource_filters.nil? || @resource_filters == []
      attrs = "#{attrs} and not(resource-filter)"
    else
      @resource_filters.each do |rf|
        attrs = "#{attrs} and resource-filter/@field = '#{rf['field']}' and resource-filter/text() = '#{rf['filter']}'"
      end
    end
    attrs = "#{attrs}]"
    doc.elements[attrs]
  end
end

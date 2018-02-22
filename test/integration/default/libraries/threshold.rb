# frozen_string_literal: true
require 'rexml/document'
class Threshold < Inspec.resource(1)
  name 'threshold'

  desc '
    OpenNMS threshold
  '

  example '
    ping = {
      \'ds_name\' => \'icmp\',
      \'group\' => \'cheftest\',
      \'type\' => \'high\',
      \'ds_type\' => \'if\',
    }
    describe threshold(ping) do
      it { should exist }
      its(\'description\') { should eq \'ping latency too high\' }
      its(\'value\') { should eq 20_000.0 }
      its(\'rearm\') { should eq 18_000.0 }
      its(\'trigger\') { should eq 2 }
    end
  '

  def initialize(threshold)
    @group = threshold['group']
    @ds_name = threshold['ds_name']
    @ds_type = threshold['ds_type']
    @type = threshold['type']
    @filter_operator = threshold['filter_operator']
    @resource_filters = threshold['resource_filters']
    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/thresholds.xml').content)
    t_el = threshold_el(doc) unless doc.nil?
    @exists = !t_el.nil?
    return unless @exists
    @params = {}
    @params[:description] = t_el.attributes['description'] unless t_el.attributes['description'].nil?
    @params[:value] = t_el.attributes['value'].to_f unless t_el.attributes['value'].nil?
    @params[:rearm] = t_el.attributes['rearm'].to_f unless t_el.attributes['rearm'].nil?
    @params[:trigger] = t_el.attributes['trigger'].to_i unless t_el.attributes['trigger'].nil?
    @params[:ds_label] = t_el.attributes['ds-label'] unless t_el.attributes['ds-label'].nil?
    @params[:triggered_uei] = t_el.attributes['triggeredUEI'] unless t_el.attributes['triggeredUEI'].nil?
    @params[:rearmed_uei] = t_el.attributes['rearmedUEI'] unless t_el.attributes['rearmedUEI'].nil?
  end

  def exist?
    @exists
  end

  def method_missing(name)
    @params[name]
  end

  private

  def threshold_el(doc)
    attrs = "/thresholding-config/group[@name = '#{@group}']/threshold[@ds-name = '#{@ds_name}' and @ds-type = '#{@ds_type}' and @type = '#{@type}'"
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

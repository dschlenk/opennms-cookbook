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
      \'triggered_uei\' => \'uei\',
      \'rearmed_uei\' => \'anotheruei\',
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
    @triggered_uei = threshold['triggered_uei']
    @rearmed_uei = threshold['rearmed_uei']
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
    attrs = if @triggered_uei.nil?
              "#{attrs} and not(@triggeredUEI)"
            else
              "#{attrs} and @triggeredUEI = '#{@triggered_uei}'"
            end
    attrs = if @rearmed_uei.nil?
              "#{attrs} and not(@rearmedUEI)"
            else
              "#{attrs} and @rearmedUEI = '#{@rearmed_uei}'"
            end
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

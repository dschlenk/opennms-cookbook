include ResourceType
include Threshold
include Events

def whyrun_supported?
    true
end

use_inline_resources

action :create do
  if @current_resource.exists
    Chef::Log.info "#{ @new_resource } already exists - nothing to do."
  else
    converge_by("Create #{ @new_resource }") do
      create_threshold
      new_resource.updated_by_last_action(true)
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsThreshold.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.group(@new_resource.group)
  @current_resource.ds_type(@new_resource.ds_type)
  @current_resource.triggered_uei(@new_resource.triggered_uei) unless @new_resource.triggered_uei.nil?
  @current_resource.rearmed_uei(@new_resource.rearmed_uei) unless @new_resource.rearmed_uei.nil?

  if group_exists?(@current_resource.group, node)
    @current_resource.group_exists = true
    if threshold_exists?(@current_resource.name, @current_resource.group, node)
      @current_resource.exists = true
      if rt_exists?(node['opennms']['conf']['home'], @current_resource.ds_type) && rt_included?(node['opennms']['conf']['home'], @current_resource.ds_type)
        @current_resource.ds_type_exists = true
        if uei_exists?(@current_resource.triggered_uei, node) && uei_exists?(@current_resource.rearmed_uei, node)
          @current_resource.ueis_exist = true
        end
      end
    end
  end
end

private


def create_threshold
  Chef::Log.debug "Adding threshold : '#{ new_resource.name }' to group: '#{new_resource.group}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/thresholds.xml")
  contents = file.read
  doc = REXML::Document.new(contents, { :respect_whitespace => :all })
  doc.context[:attribute_quote] = :quote
  file.close

  threshold_el = REXML::Element.new 'threshold'
  threshold_el.attributes['ds-name'] = new_resource.name
  threshold_el.attributes['type'] = new_resource.type
  threshold_el.attributes['ds-type'] = new_resource.ds_type
  threshold_el.attributes['value'] = new_resource.value
  threshold_el.attributes['rearm'] = new_resource.rearm
  threshold_el.attributes['trigger'] = new_resource.trigger
  threshold_el.attributes['description'] = new_resource.description unless new_resource.description.nil?
  threshold_el.attributes['ds-label'] = new_resource.ds_label unless new_resource.ds_label.nil?
  threshold_el.attributes['triggeredUEI'] = new_resource.triggered_uei unless new_resource.triggered_uei.nil?
  threshold_el.attributes['rearmedUEI'] = new_resource.rearmed_uei unless new_resource.rearmed_uei.nil?
  threshold_el.attributes['filterOperator'] = new_resource.filter_operator unless new_resource.filter_operator.nil? || new_resource.filter_operator == 'or'
  if !new_resource.resource_filters.nil?
    new_resource.resource_filters.each do |filter|
      filter_el = threshold_el.add_element 'resource-filter', {'field' => filter['field']}
      filter_el.add_text(REXML::CData.new(filter['filter']))
    end
  end

  group_el = doc.root.elements["/thresholding-config/group[@name = '#{new_resource.group}']"]
  # see if there's an existing threshold element
  last_threshold_el = group_el.elements["threshold[last()]"]
  if !last_threshold_el.nil?
    group_el.insert_after(last_threshold_el, threshold_el)
  else
    first_expression_el = group_el.elements["expression[1]"]
    if !first_expression_el.nil?
      group_el.insert_before(first_expression_el, threshold_el)
    else
      group_el.add_element threshold_el
    end
  end
  out = ""
  formatter = REXML::Formatters::Pretty.new(2)
  formatter.compact = true
  formatter.write(doc, out)
  ::File.open("#{node['opennms']['conf']['home']}/etc/thresholds.xml", "w"){ |file| file.puts(out) }
end

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
      create_expression
      new_resource.updated_by_last_action(true)
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsExpression.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.group(@new_resource.group)
  @current_resource.ds_type(@new_resource.ds_type)
  @current_resource.triggered_uei(@new_resource.triggered_uei)
  @current_resource.rearmed_uei(@new_resource.rearmed_uei)

  if group_exists?(@current_resource.group, node)
    @current_resource.group_exists = true
    if expression_exists?(@current_resource.name, @current_resource.group, node)
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


def create_expression
  Chef::Log.debug "Adding expression: '#{ new_resource.name }' to group: '#{new_resource.group}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/thresholds.xml")
  contents = file.read
  doc = REXML::Document.new(contents, { :respect_whitespace => :all })
  doc.context[:attribute_quote] = :quote
  file.close

  expression_el = REXML::Element.new 'expression' 
  expression_el.attributes['expression'] = new_resource.name
  expression_el.attributes['type'] = new_resource.type
  expression_el.attributes['ds-type'] = new_resource.ds_type 
  expression_el.attributes['value'] = new_resource.value
  expression_el.attributes['rearm'] = new_resource.rearm 
  expression_el.attributes['trigger'] = new_resource.trigger
  expression_el.attributes['relaxed'] = new_resource.relaxed unless new_resource.relaxed.nil?
  expression_el.attributes['description'] = new_resource.description unless new_resource.description.nil?
  expression_el.attributes['ds-label'] = new_resource.ds_label unless new_resource.ds_label.nil?
  expression_el.attributes['triggeredUEI'] = new_resource.triggered_uei unless new_resource.triggered_uei.nil?
  expression_el.attributes['rearmedUEI'] = new_resource.rearmed_uei unless new_resource.rearmed_uei.nil?
  expression_el.attributes['filterOperator'] = new_resource.filter_operator unless new_resource.filter_operator.nil? || new_resource.filter_operator == 'or'
  if !new_resource.resource_filters.nil?
    new_resource.resource_filters.each do |filter|
      filter_el = expression_el.add_element 'resource-filter', {'field' => filter['field']}
      filter_el.add_text(REXML::CData.new(filter['filter']))
    end
  end

  group_el = doc.root.elements["/thresholding-config/group[@name = '#{new_resource.group}']"]
  # see if there's an existing expression element
  last_expression_el = group_el.elements["expression[last()]"]
  if !last_expression_el.nil?
    group_el.insert_after(last_expression_el, expression_el)
  else
    last_threshold_el = group_el.elements["threshold[last()]"]
    if !last_threshold_el.nil?
      group_el.insert_after(last_threshold_el, expression_el)
    else
      group_el.add_element expression_el
    end
  end

  out = ""
  formatter = REXML::Formatters::Pretty.new(2)
  formatter.compact = true
  formatter.write(doc, out)
  ::File.open("#{node['opennms']['conf']['home']}/etc/thresholds.xml", "w"){ |file| file.puts(out) }
end

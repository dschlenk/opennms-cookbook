# frozen_string_literal: true
include Threshold
def whyrun_supported?
  true
end

use_inline_resources

action :create do
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  else
    converge_by("Create #{@new_resource}") do
      create_threshold_group
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsThresholdGroup.new(@new_resource.name)
  @current_resource.name(@new_resource.name)

  @current_resource.exists = true if group_exists?(@current_resource.name, node)
end

private

def create_threshold_group
  Chef::Log.debug "Adding thresholding group: '#{new_resource.name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/thresholds.xml")
  contents = file.read
  doc = REXML::Document.new(contents, respect_whitespace: :all)
  doc.context[:attribute_quote] = :quote
  file.close

  group_el = REXML::Element.new 'group'
  group_el.attributes['name'] = new_resource.name
  group_el.attributes['rrdRepository'] = new_resource.rrd_repository

  last_group_el = doc.root.elements['/thresholding-config/group[last()]']
  if !last_group_el.nil?
    doc.root.insert_after(last_group_el, group_el)
  else
    doc.root.add_element group_el
  end

  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/thresholds.xml")
end

# frozen_string_literal: true
def whyrun_supported?
  true
end

use_inline_resources

action :create do
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  else
    converge_by("Create #{@new_resource}") do
      create_collection_package
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsCollectionPackage.new(@new_resource.name)
  @current_resource.name(@new_resource.name)

  @current_resource.exists = true if package_exists?(@current_resource.name)
end

private

def package_exists?(name)
  Chef::Log.debug "Checking to see if this collection package exists: '#{name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/collectd-configuration.xml", 'r')
  doc = REXML::Document.new file
  !doc.elements["/collectd-configuration/package[@name='#{name}']"].nil?
end

def create_collection_package
  Chef::Log.debug "Adding collection package: '#{new_resource.name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/collectd-configuration.xml")
  contents = file.read
  doc = REXML::Document.new(contents, respect_whitespace: :all)
  doc.context[:attribute_quote] = :quote
  file.close

  last_pkg_el = doc.root.elements['/collectd-configuration/package[last()]']
  doc.root.insert_after(last_pkg_el, REXML::Element.new('package'))
  package_el = doc.root.elements['/collectd-configuration/package[last()]']
  package_el.attributes['name'] = new_resource.name
  filter_el = package_el.add_element('filter')
  filter_el.add_text(REXML::CData.new(new_resource.filter))
  new_resource.specifics.each do |specific|
    specific_el = package_el.add_element('specific')
    specific_el.add_text(specific)
  end
  new_resource.include_ranges.each do |include_range|
    include_range_el = package_el.add_element('include-range')
    include_range_el.add_attribute('begin', include_range['begin'])
    include_range_el.add_attribute('end', include_range['end'])
  end
  new_resource.exclude_ranges.each do |exclude_range|
    exclude_range_el = package_el.add_element('exclude-range')
    exclude_range_el.add_attribute('begin', exclude_range['begin'])
    exclude_range_el.add_attribute('end', exclude_range['end'])
  end
  new_resource.include_urls.each do |include_url|
    include_url_el = package_el.add_element('include-url')
    include_url_el.add_text(include_url)
  end
  if new_resource.store_by_if_alias == true
    sb_ifalias_el = package_el.add_element('storeByIfAlias')
    sb_ifalias_el.add_text('true')
  end
  if new_resource.store_by_node_id != 'normal'
    sb_nodeid_el = package_el.add_element('storeByNodeID')
    sb_nodeid_el.add_text(new_resource.store_by_node_id)
  end
  unless new_resource.if_alias_domain.nil?
    ifalias_domain_el = package_el.add_element('ifAliasDomain')
    ifalias_domain_el.add_text(new_resource.if_alias_domain)
  end
  if new_resource.stor_flag_override
    stor_flag_override_el = package_el.add_element('storFlagOverride')
    stor_flag_override_el.add_text('true')
  end
  unless new_resource.if_alias_comment.nil?
    ifalias_comment_el = package_el.add_element('ifAliasComment')
    ifalias_comment_el.add_text(new_resource.if_alias_comment)
  end

  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/collectd-configuration.xml")
end

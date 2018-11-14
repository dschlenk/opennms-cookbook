# frozen_string_literal: true
def whyrun_supported?
  true
end

use_inline_resources # ~FC113

action :create do
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
		if @current_resource.different
			  converge_by("Update #{@new_resource}") do
				  update_collection_package
			  end
		else
			Chef::Log.info "#{@new_resource} hasn't changed - nothing to do."
		end
  else
    converge_by("Create #{@new_resource}") do
      create_collection_package
    end
  end
end

action :create_if_missing do
	if @current_resource.exists
		Chef::Log.info "#{@new_resource} already exists - nothing to do."
	else
		converge_by("Create #{@new_resource}") do
			create_collection_package
		end
	end
end

action :delete do
	if !@current_resource.exists
		Chef::Log.info "#{@new_resource} doesn't exist - nothing to do."
	else
		converge_by("Delete #{@new_resource}") do
			delete_collection_package
		end
	end
end

def load_current_resource
  @current_resource = Chef::Resource.resource_for_node(:opennms_collection_package, node).new(@new_resource.name)

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
  package_el.attributes['remote'] = new_resource.remote unless new_resource.remote.nil?
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
  unless new_resource.outage_calendars.nil?
    new_resource.outage_calendars.each do |oc|
      oc_el = package_el.add_element('outage-calendar')
      oc_el.add_text(oc)
    end
  end

  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/collectd-configuration.xml")
end

def update_collection_package
	Chef::Log.debug "Updating collectd-configuration.xml definition : '#{new_resource.name}'"
	file = ::File.new("#{node['opennms']['conf']['home']}/etc/collectd-configuration.xml")
	contents = file.read
	doc = REXML::Document.new(contents, respect_whitespace: :all)
	doc.context[:attribute_quote] = :quote
	file.close
	
	package_el = matching_package_name(doc, new_resource)

	# put the new ones in
	unless new_resource.filter.nil?
		new_resource.filter.each do |filter|
		if package_el.elements["filter[text() = '#{filter}']"].nil?
			filter_el = package_el.add_element 'filter'
			filter_el.add_text(filter)
			end
		end
	end
	unless new_resource.specifics.nil?
		new_resource.specifics.each do |specific|
			if package_el.elements["specific[text() = '#{specific}']"].nil?
				specific_el = package_el.add_element 'specific'
				specific_el.add_text(specific)
			end
		end
	end
	unless new_resource.include_ranges.nil?
		new_resource.include_ranges.each do |r_begin, r_end|
			if !package_el.nil? && package_el.elements["include-range[@begin = '#{r_begin}' and @end = '#{r_end}']"].nil?
				package_el.add_element 'include-range', 'begin' => r_begin, 'end' => r_end
			end
		end
	end
	unless new_resource.exclude_ranges.nil?
		new_resource.exclude_ranges.each do |r_begin, r_end|
			if !package_el.nil? && package_el.elements["exclude-range[@begin = '#{r_begin}' and @end = '#{r_end}']"].nil?
				package_el.add_element 'exclude_range', 'begin' => r_begin, 'end' => r_end
			end
		end
	end
	unless new_resource.include_urls.nil?
		new_resource.include_urls.each do |include_url|
			if package_el.elements["include-url[text() = '#{include_url}']"].nil?
				include_url_el = package_el.add_element 'include-url'
				include_url_el.add_text(include_url)
			end
		end
	end
	unless new_resource.store_by_if_alias.nil?
		new_resource.store_by_if_alias.each do |storeByIfAlias|
			if package_el.elements["storeByIfAlias[text() = '#{storeByIfAlias}']"].nil?
				sb_ifalias_el = package_el.add_element 'storeByIfAlias'
				sb_ifalias_el.add_text(storeByIfAlias)
			end
		end
	end
	unless new_resource.store_by_node_id.nil?
		new_resource.store_by_node_id.each do |storeByNodeID|
			if package_el.elements["storeByNodeID[text() = '#{storeByNodeID}']"].nil?
				sb_nodeid_el = package_el.add_element 'storeByNodeID'
				sb_nodeid_el.add_text(storeByNodeID)
			end
		end
	end
	unless new_resource.if_alias_domain.nil?
		new_resource.if_alias_domain.each do |ifAliasDomain|
			if package_el.elements["ifAliasDomain[text() = '#{ifAliasDomain}']"].nil?
				ifalias_domain_el = package_el.add_element 'ifAliasDomain'
				ifalias_domain_el.add_text(storeByNodeID)
			end
		end
	end
	unless new_resource.stor_flag_override.nil?
		new_resource.stor_flag_override.each do |storFlagOverride|
			if package_el.elements["storFlagOverride[text() = '#{storFlagOverride}']"].nil?
				stor_flag_override_el = package_el.add_element 'storFlagOverride'
				stor_flag_override_el.add_text(storFlagOverride)
			end
		end
	end
	unless new_resource.if_alias_comment.nil?
		new_resource.if_alias_comment.each do |ifAliasComment|
			if package_el.elements["ifAliasComment[text() = '#{ifAliasComment}']"].nil?
				ifalias_comment_el = package_el.add_element 'ifAliasComment'
				ifalias_comment_el.add_text(ifAliasComment)
			end
		end
	end
	unless new_resource.outage_calendars.nil?
		new_resource.outage_calendars.each do |oc|
			if package_el.elements["outage-calendar[text() = '#{oc}']"].nil?
				oc_el = package_el.add_element 'outage-calendar'
				oc_el.add_text(oc)
			end
		end
	end
	
	Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/collectd-configuration.xml")
end

def matching_package_name(doc, current_resource)
	definition = nil
	doc.elements.each('/collectd-configuration/package') do |package_name|
		next unless package_name.attributes['name'].to_s == current_resource.name.to_s\
    && package_name.attributes['remote'].to_s == current_resource.remote.to_s
		definition = package_name
		break
	end
	definition
end

def delete_collection_package
	Chef::Log.debug "Deleting collectd-configuration.xml definition : '#{new_resource.name}'"
	file = ::File.new("#{node['opennms']['conf']['home']}/etc/collectd-configuration.xml", 'r')
	contents = file.read
	file.close
	doc = REXML::Document.new(contents, respect_whitespace: :all)
	doc.context[:attribute_quote] = :quote
	
	package_el = matching_package_name(doc, new_resource)
	doc.root.delete(package_el)
	
	Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/collectd-configuration.xml")
end

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
	@current_resource.filter(@new_resource.filter)
	@current_resource.specifics(@new_resource.specifics)
	@current_resource.include_ranges(@new_resource.include_ranges)
	@current_resource.exclude_ranges(@new_resource.exclude_ranges)
	@current_resource.include_urls(@new_resource.include_urls)
	@current_resource.store_by_if_alias(@new_resource.store_by_if_alias)
	@current_resource.store_by_node_id(@new_resource.store_by_node_id)
	@current_resource.if_alias_domain(@new_resource.if_alias_domain)
	@current_resource.stor_flag_override(@new_resource.stor_flag_override)
	@current_resource.if_alias_comment(@new_resource.if_alias_comment)
	@current_resource.outage_calendars(@new_resource.outage_calendars)
	
	file = ::File.new("#{node['opennms']['conf']['home']}/etc/collectd-configuration.xml", 'r')
	contents = file.read
	file.close
	
	doc = REXML::Document.new(contents, respect_whitespace: :all)
	doc.context[:attribute_quote] = :quote
	package_el = matching_package_name(doc, @current_resource)
	
	if !package_el.nil?
		@current_resource.exists = true
	  if filter_change?(package_el, @current_resource.filter) || specifics_change?(package_el, @current_resource.specifics) || include_ranges_change?(package_el, @current_resource.include_ranges)
			Chef::Log.debug("uei #{@current_resource.name} has changed.")
			@current_resource.different = true
	  end
	end
end



private

def matching_package_name(doc, current_resource)
	definition = nil
	doc.elements.each('/collectd-configuration/package') do |package_name|
		next unless package_name.attributes['name'].to_s == current_resource.to_s
		definition = package_name
		break
	end
	definition
end

def filter_change?(package_el, current_filter)
	filter_el = package_el.elements['filter'].text.to_s
	Chef::Log.debug "Filter ? New: #{current_filter.filter}; Current: #{filter_el}"
	return true unless filter_el == current_filter.filter
end

def specifics_change?(package_el, specifics)
	Chef::Log.debug("Check for no specifics: #{package_el.elements['specific'].nil?} && #{specifics}")
	return false if package_el.elements['specific'].nil? && (specifics.nil? || specifics.empty?)
	curr_specifics = []
	package_el.elements.each('specific') do |specific|
		curr_specifics.push specific.text
	end
	curr_specifics.sort!
	Chef::Log.debug("specifics equal? #{curr_specifics} == #{specifics}")
	sorted_specifics = nil
	sorted_specifics = specifics.sort unless specifics.nil?
	return true unless curr_specifics == sorted_specifics
end

def include_ranges_change?(package_el, include_ranges)
	Chef::Log.debug("Check for no ranges: #{package_el.elements['include-range'].nil?} && #{include_ranges}")
	return false if package_el.elements['include-range'].nil? && (include_ranges.nil? || include_ranges.empty?)
	curr_include_ranges = {}
	package_el.elements.each('include-range') do |ncr_el|
		curr_include_ranges[ncr_el.attributes['begin']] = ncr_el.attributes['end']
	end
	return true unless curr_include_ranges == include_ranges
end

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
	
	package_el = matching_package_name(doc, new_resource.name)
	
	filter_el = package_el.add_element('filter')
	filter_el.add_text(REXML::CData.new(new_resource.filter))

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
	if new_resource.stor_flag_override == true
		stor_flag_override_el = package_el.add_element('storFlagOverride')
		stor_flag_override_el.add_text('true')
	end
	unless new_resource.if_alias_comment.nil?
		ifalias_comment_el = package_el.add_element('ifAliasComment')
		ifalias_comment_el.add_text(new_resource.if_alias_comment)
	end
	unless new_resource.outage_calendars.nil?
		new_resource.outage_calendars.each do |oc|
			if package_el.elements["outage-calendar[text() = '#{oc}']"].nil?
				oc_el = package_el.add_element ('outage-calendar')
				oc_el.add_text(oc)
			end
		end
	end
	Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/collectd-configuration.xml")
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

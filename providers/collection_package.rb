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
	@current_resource.name(@new_resource.name) unless @new_resource.name.nil?
	@current_resource.remote(@new_resource.remote) unless @new_resource.remote.nil?
	
	@current_resource.filter(@new_resource.filter) unless @new_resource.filter.nil?
	@current_resource.specifics(@new_resource.specifics) unless @new_resource.specifics.nil?
	@current_resource.include_ranges(@new_resource.include_ranges) unless @new_resource.include_ranges.nil?
	@current_resource.exclude_ranges(@new_resource.exclude_ranges) unless @new_resource.exclude_ranges.nil?
	@current_resource.include_urls(@new_resource.include_urls) unless @new_resource.include_urls.nil?
	@current_resource.store_by_if_alias(@new_resource.store_by_if_alias) unless @new_resource.store_by_if_alias.nil?
	@current_resource.store_by_node_id(@new_resource.store_by_node_id) unless @new_resource.store_by_node_id.nil?
	@current_resource.if_alias_domain(@new_resource.if_alias_domain) unless @new_resource.if_alias_domain.nil?
	@current_resource.stor_flag_override(@new_resource.stor_flag_override) unless @new_resource.stor_flag_override.nil?
	@current_resource.if_alias_comment(@new_resource.if_alias_comment) unless @new_resource.if_alias_comment.nil?
	@current_resource.outage_calendars(@new_resource.outage_calendars) unless @new_resource.outage_calendars.nil?
	
	file = ::File.new("#{node['opennms']['conf']['home']}/etc/collectd-configuration.xml", 'r')
	contents = file.read
	file.close
	
	doc = REXML::Document.new(contents, respect_whitespace: :all)
	doc.context[:attribute_quote] = :quote
	package_el = matching_package(doc, @new_resource)
	
	if !package_el.nil?
		@current_resource.exists = true if package_exists?(@current_resource.name)
		@current_resource.different = if filter_equal?(package_el, @current_resource.filter) \
	                                   && specifics_equal?(package_el, @current_resource.specifics) \
	                                   && include_ranges_equal?(package_el, @current_resource.include_ranges) \
	                                   && exclude_ranges_equal?(package_el, @current_resource.exclude_ranges) \
	                                   && include_urls_equal?(package_el, @current_resource.include_urls) \
	                                   && store_by_if_alias_equal?(package_el, @current_resource.store_by_if_alias) \
	                                   && store_by_node_id_equal?(package_el, @current_resource.store_by_node_id) \
	                                   && if_alias_domain_equal?(package_el, @current_resource.if_alias_domain) \
	                                   && stor_flag_override_equal?(package_el, @current_resource.stor_flag_override) \
	                                   && if_alias_comment_equal?(package_el, @current_resource.if_alias_comment) \
	                                   && outage_calendars_equal?(package_el, @current_resource.outage_calendars)
			                              false
			                            else
				                            true
		                              end
	else
		@current_resource.different = true
	end
end

private

def matching_package(doc, current_resource)
	package = nil
	doc.elements.each('/collectd-configuration/package') do |package_el|
		next unless package_el.attributes['name'].to_s == current_resource.name.to_s\
                              && package_el.attributes['remote'].to_s == current_resource.remote.to_s
		package = package_el
		break
	end
	package
end


def filter_equal?(doc, current_filter)
	Chef::Log.debug("Filter ? New: #{doc.elements['filter'].nil?} && #{current_filter}")
	return true if doc.elements['filter'].nil? && (current_filter.nil? || current_filter.empty?)
	
	filter_el = doc.elements['filter'].to_s
	filter_el == current_filter
end

def specifics_equal?(doc, specifics)
	Chef::Log.debug("Check for no specifics: #{doc.elements['specific'].nil?} && #{specifics}")
	return true if doc.elements['specific'].nil? && (specifics.nil? || specifics.empty?)
	
	curr_specifics = []
	doc.elements.each('specific') do |specific|
		curr_specifics.push specific.text
	end
	curr_specifics.sort!
	Chef::Log.debug("specifics equal? #{curr_specifics} == #{specifics}")
	sorted_specifics = nil
	sorted_specifics = specifics.sort unless specifics.nil?
	curr_specifics == sorted_specifics
end

def include_ranges_equal?(doc, include_ranges)
	Chef::Log.debug("Check for include ranges: #{doc.elements['include-range'].nil?} && #{include_ranges}")
	return true if doc.elements['include-range'].nil? && (include_ranges.nil? || include_ranges.empty?)
	
	doc.elements.each('include-range') do |ncr_el|
		ncr_el.attributes['begin'].to_s == include_ranges['begin'].to_s && ncr_el.attributes['end'].to_s == include_ranges['end'].to_s
	end

end

def exclude_ranges_equal?(doc, exclude_ranges)
	Chef::Log.debug("Check for exclude-range: #{doc.elements['exclude-range'].nil?} && #{exclude_ranges}")
	return true if doc.elements['exclude-range'].nil? && (exclude_ranges.nil? || exclude_ranges.empty?)
	
	doc.elements.each('exclude-range') do |exl_el|
		exl_el.attributes['begin'].to_s == exclude_ranges['begin'].to_s && exl_el.attributes['end'].to_s == exclude_ranges['end'].to_s
	end

end

def include_urls_equal?(doc, include_urls)
	Chef::Log.debug("Check for no include_urls: #{doc.elements['include-url'].nil?} && #{include_urls}")
	return true if doc.elements['include-url'].nil? && (include_urls.nil? || include_urls.empty?)
	
	curr_include_urls = []
	doc.elements.each('include-url') do |urls|
		curr_include_urls.push urls.text
	end
	curr_include_urls.sort!
	Chef::Log.debug("include-url equal? #{curr_specifics} == #{include_urls}")
	sorted_include_urls = nil
	sorted_include_urls = include_urls.sort unless include_urls.nil?
	curr_include_urls == sorted_include_urls
end

def store_by_if_alias_equal?(doc, store_by_if_alia)
	return true if doc.elements['storeByIfAlias'].nil? && (store_by_if_alia.nil? || store_by_if_alia.empty?)
	
	store_by_if_alias_el = doc.elements['storeByIfAlias'].to_s
	Chef::Log.debug "storeByIfAlias ? New: #{store_by_if_alia}; Current: #{store_by_if_alias_el}"
	store_by_if_alias_el == store_by_if_alia
end

def store_by_node_id_equal?(doc, store_by_node_id)
	return true if doc.elements['storeByNodeID'].nil? && (store_by_node_id.nil? || store_by_node_id.empty?)
	
	store_by_node_id_el = doc.elements['storeByNodeID'].to_s
	Chef::Log.debug "storeByNodeID ? New: #{store_by_node_id}; Current: #{store_by_node_id_el}"
	store_by_node_id_el == store_by_node_id
end

def if_alias_domain_equal?(doc, if_alias_domain)
	return true if doc.elements['ifAliasDomain'].nil? && (if_alias_domain.nil? || if_alias_domain.empty?)
	
	if_alias_domain_el = doc.elements['ifAliasDomain'].to_s
	Chef::Log.debug "ifAliasDomain ? New: #{if_alias_domain}; Current: #{if_alias_domain_el}"
	if_alias_domain_el == if_alias_domain
end

def stor_flag_override_equal?(doc, stor_flag_override)
	return true if doc.elements['storFlagOverride'].nil? && (stor_flag_override.nil? || stor_flag_override.empty?)
	
	stor_flag_override_el = doc.elements['storFlagOverride'].to_s
	Chef::Log.debug "storFlagOverride ? New: #{stor_flag_override}; Current: #{stor_flag_override_el}"
	stor_flag_override_el == stor_flag_override
end

def if_alias_comment_equal?(doc, if_alias_comment)
	return true if doc.elements['ifAliasComment'].nil? && (if_alias_comment.nil? || if_alias_comment.empty?)
	
	if_alias_comment_el = doc.elements['ifAliasComment'].to_s
	Chef::Log.debug "ifAliasComment ? New: #{if_alias_comment}; Current: #{if_alias_comment_el}"
	if_alias_comment_el == if_alias_comment
end

def outage_calendars_equal?(doc, outage_calendars)
	return true if doc.elements['outage-calendar'].nil? && (outage_calendars.nil? || outage_calendars.empty?)
	
	outage_calendars_el = doc.elements['outage-calendar'].to_s
	Chef::Log.debug "outage-calendar ? New: #{outage_calendars}; Current: #{outage_calendars_el}"
	outage_calendars_el == outage_calendars
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
	file = ::File.new("#{node['opennms']['conf']['home']}/etc/collectd-configuration.xml", 'r')
	contents = file.read
	file.close
	
	doc = REXML::Document.new(contents, respect_whitespace: :all)
	doc.context[:attribute_quote] = :quote
	
	package_el = matching_package(doc, new_resource)
	
	if !package_el.nil?
		unless new_resource.filter.nil?
			package_el.delete_element "filter"
			filter_el = package_el.add_element 'filter'
			filter_el.add_text(REXML::CData.new(new_resource.filter))
		end
		unless new_resource.specifics.nil?
			new_resource.specifics.each do |specific|
				unless specific.nil? && specific.empty?
					package_el.delete_element "specific"
				end
			end
			new_resource.specifics.each do |specific|
				sel = package_el.add_element 'specific'
				sel.add_text(specific)
			end
		end
		unless new_resource.include_ranges.nil?
			new_resource.include_ranges.each do |include_range|
				unless include_range.nil? && include_range.empty?
					package_el.delete_element "include-range"
				end
			end
			new_resource.include_ranges.each do |include_range|
				include_range_el = package_el.add_element('include-range')
				include_range_el.add_attribute('begin', include_range['begin'])
				include_range_el.add_attribute('end', include_range['end'])
			end
		end
		unless new_resource.exclude_ranges.nil?
			new_resource.exclude_ranges.each do |exclude_range|
				unless exclude_range.nil? && exclude_range.empty?
					package_el.delete_element "exclude-range"
				end
			end
			new_resource.exclude_ranges.each do |exclude_range|
				exclude_range_el = package_el.add_element('exclude-range')
				exclude_range_el.add_attribute('begin', exclude_range['begin'])
				exclude_range_el.add_attribute('end', exclude_range['end'])
			end
		end
		unless new_resource.include_urls.nil?
			new_resource.include_urls.each do |include_url|
				unless include_url.nil? && include_url.empty?
					package_el.delete_element 'include-url'
				end
			end
			new_resource.include_urls.each do |include_url|
				include_url_el = package_el.add_element 'include-url'
				include_url_el.add_text(include_url)
			end
		end
		unless new_resource.store_by_if_alias.nil?
			if new_resource.store_by_if_alias == true
				sb_ifalias_el = package_el.add_element 'storeByIfAlias'
				sb_ifalias_el.add_text('true')
			end
		end
		unless new_resource.store_by_node_id.nil?
			package_el.delete_element 'storeByNodeID'
			sb_nodeid_el = package_el.add_element 'storeByNodeID'
			sb_nodeid_el.add_text(new_resource.store_by_node_id)
		end
		unless new_resource.if_alias_domain.nil? || new_resource.if_alias_domain.empty?
			package_el.delete_element 'ifAliasDomain'
			dm_ifalias_el = package_el.add_element 'ifAliasDomain'
			dm_ifalias_el.add_text(new_resource.if_alias_domain)
		end
		unless new_resource.stor_flag_override.nil? || new_resource.stor_flag_override.empty?
			package_el.delete_element 'storFlagOverride'
			stor_flag_override_el = package_el.add_element 'storFlagOverride'
			stor_flag_override_el.add_text(new_resource.stor_flag_override)
		end
		unless new_resource.if_alias_comment.nil? || new_resource.if_alias_comment.empty?
			package_el.delete_element 'ifAliasComment'
			ifalias_comment_el = package_el.add_element 'ifAliasComment'
			ifalias_comment_el.add_text(new_resource.if_alias_comment)
		end
		unless new_resource.outage_calendars.nil?
			new_resource.outage_calendars.each do |oc|
				unless oc.nil? && oc.empty?
					package_el.delete_element 'outage-calendar'
				end
				new_resource.outage_calendars.each do |oc|
					oc_el = package_el.add_element 'outage-calendar'
					oc_el.add_text(oc)
				end
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
	
	package_el = matching_package(doc, new_resource)
	doc.root.delete(package_el)
	Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/collectd-configuration.xml")
end

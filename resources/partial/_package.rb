include Opennms::XmlHelper
unified_mode true

property :package_name, String, name_attribute: true
property :filter, String, required: true
property :specifics, Array, default: []
property :include_ranges, Array, default: []
property :exclude_ranges, Array, default: []
property :include_urls, Array, default: []
property :outage_calendars, Array

action_class do
  include Opennms::XmlHelper
end

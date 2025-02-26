include Opennms::XmlHelper
unified_mode true

property :package_name, String, name_attribute: true
property :filter, String, required: true
property :specifics, Array
property :include_ranges, Array
property :exclude_ranges, Array
property :include_urls, Array
property :outage_calendars, Array

action_class do
  include Opennms::XmlHelper
end

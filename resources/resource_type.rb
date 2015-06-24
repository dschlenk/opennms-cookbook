require 'rexml/document'

# Define a resource type in datacollection-config.xml
# The XML makes it look like there's a relationship between resourceTypes and 
# the group they exist in and maybe even the collection they are included in, 
# but they don't and furthermore if you end up defining a resource type 
# more than once whatever one gets seen first wins and subsequent 
# definitions are ignored. In an effort to to avoid these issues, by convention
# we add groups in alphabetical order to the 'default' snmp-collection, and we 
# check all files in etc/datacollection/ for an existing resourceType definition
# so if you have duplicate resource types defined in your run list, only the 
# first one will end up getting converged. 

actions :create
default_action :create

attribute :type_name, :kind_of => String, :default => nil
attribute :group_name, :kind_of => String, :default => nil
attribute :label, :kind_of => String, :default => nil
attribute :resource_label, :kind_of => String, :default => '${resource} (index:${index})'
attribute :persistence_selector_strategy, :kind_of => String, :default => 'org.opennms.netmgt.collection.support.PersistAllSelectorStrategy'
# Must be an array of single key/value hashes with quoted string key names.
attribute :persistence_selector_strategy_params, :kind_of => Array, :default => []
attribute :storage_strategy, :kind_of => String, :default => 'org.opennms.netmgt.collection.support.IndexStorageStrategy'
# Must be an array of single key/value hashes with quoted string key names.
attribute :storage_strategy_params, :kind_of => Array, :default => []

attr_accessor :exists, :included

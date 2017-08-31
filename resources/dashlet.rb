# frozen_string_literal: true
require 'rexml/document'

# Manages a dashlet in a wallboard element for the Ops Board feature.
# Doesn't validate parameters.
actions :create
default_action :create

attribute :title, kind_of: String, name_attribute: true
attribute :wallboard, kind_of: String, required: true
attribute :boost_duration, kind_of: Integer, default: 0
attribute :boost_priority, kind_of: Integer, default: 0
attribute :duration, kind_of: Integer, default: 15
attribute :priority, kind_of: Integer, default: 5
# not to be confused with the name of the resource aka title.
# this is actually the type of dashlet, but we'll follow the naming used in the XMl file.
attribute :dashlet_name, kind_of: String, equal_to: ['Surveillance', 'RTC', 'Summary', 'Alarm Details', 'Alarms', 'Charts', 'Image', 'KSC', 'Map', 'RRD', 'Topology', 'URL'], required: true
# simple key / value hash of strings
attribute :parameters, kind_of: Hash, default: {}

attr_accessor :wallboard_exists, :exists, :changed

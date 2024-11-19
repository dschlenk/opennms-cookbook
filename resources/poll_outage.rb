property :outage_name, String
# "id" => { "day" => "(monday|tuesday|wednesday|thursday|friday|saturday|sunday|[1-3][0-9]|[1-9])", "begins" => "dd-MMM-yyyy HH:mm:ss", "ends" => "HH:mm:ss" }
property :times, Hash, required: true
property :type, String, equal_to: %w(specific daily weekly monthly), required: true
property :interfaces, Array, default: [] # of IP addresses as strings
property :nodes, Array, default: [] # of node IDs

attr_accessor :exists

# frozen_string_literal: true
%w(webopts
   resource_type
   snmp_collection
   xml_collection
   wmi_collection
   jdbc_collection
   collection_package
   collection_service
   snmp_collection_service
   xml_collection_service
   wmi_collection_service
   jdbc_collection_service
   snmp_collection_group
   jdbc_query
   wmi_wpm
   xml_source
   xml_group
   jmx
   eventconf
   event
   poller
   disco_specific
   disco_range
   disco_url
   foreign_source
   service_detector
   policy
   import
   import_node
   import_node_interface
   import_node_interface_service
   snmp_config_definition
   update_snmp_config_definition
   wmi_config_definition
   update_wmi_config_definition
   destination_path
   notification_command
   notifd_autoack
   notification
   user
   group
   role
   statsd
   collection_graph_file
   collection_graph
   response_graph
   threshold
   system_def
   avail_category
   avail_view_section
   wallboard
   dashlet
   update_dashlet
   surveillance_view
   send_event).each do |r|
  include_recipe "onms_lwrp_test::#{r}"
end

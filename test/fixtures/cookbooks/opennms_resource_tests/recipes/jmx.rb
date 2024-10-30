# frozen_string_literal: true
opennms_collection_package 'jmx1' do
  filter "IPADDR != '0.0.0.0'"
  notifies :restart, 'service[opennms]'
end

# opennms_jmx_collection 'jmxcollection'

opennms_jmx_collection_service 'jmx' do
  package_name 'jmx1'
  collection 'jmxcollection'
  ds_name 'jmx-ds-name'
  friendly_name 'jmx-friendly-name'
end

# opennms_jmx_mbean 'anQueue org.apache.activemq.Queue' do
#   mbean_name 'org.apache.activemq.Queue'
#   collection_name 'jmxcollection'
#   objectname 'org.apache.activemq:BrokerName=broker.example.com,Type=Queue,Destination=anQueue'
#   attribs(
#     'ConsumerCount' => { 'alias' => 'anQConsumerCnt', 'type' => 'gauge' },
#     'InFlightCount' => { 'alias' => 'anQFlightCnt', 'type' => 'gauge' }
#   )
# end

# opennms_jmx_mbean 'anotherQueue org.apache.activemq.Queue' do
#   mbean_name 'org.apache.activemq.Queue'
#   collection_name 'jmxcollection'
#   objectname 'org.apache.activemq:BrokerName=broker.example.com,Type=Queue,Destination=anotherQueue'
#   attribs(
#     'ConsumerCount' => { 'alias' => 'anoQConsumerCnt', 'type' => 'gauge' },
#     'InFlightCount' => { 'alias' => 'anoQInflightCnt', 'type' => 'gauge' }
#   )
# end

opennms_jmx_collection_service 'jmx_url' do
  package_name 'jmx1'
  collection 'jmxcollection'
  ds_name 'jmx-ds-name'
  friendly_name 'jmx-friendly-name'
  url 'service:jmx:rmi:${ipaddr}:18980'
  factory 'SASL'
  username 'bart'
  password 'simpson'
end

opennms_jmx_collection_service 'jmx_url_path' do
  package_name 'jmx1'
  collection 'jmxcollection'
  ds_name 'jmx-ds-name'
  friendly_name 'jmx-friendly-name'
  url_path '/jmxrmi'
  protocol 'rmi'
  rmi_server_port 45444
  remote_jmx true
  factory 'SASL'
  username 'bart'
  password 'simpson'
end

opennms_jmx_collection_service 'jmx_url_ignore_path' do
  package_name 'jmx1'
  collection 'jmxcollection'
  ds_name 'jmx-ds-name'
  friendly_name 'jmx-friendly-name'
  url 'service:jmx:rmi:${ipaddr}:18980'
  url_path '/jmxrmi'
  protocol 'rmi'
  rmi_server_port 45444
  remote_jmx true
  factory 'SASL'
  username 'bart'
  password 'simpson'
end

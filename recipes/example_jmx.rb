opennms_collection_package 'jmx1' do
  filter "IPADDR != '0.0.0.0'"
  notifies :restart, "service[opennms]"
end

opennms_jmx_collection 'jmxcollection'

opennms_jmx_collection_service 'jmx' do
  package_name 'jmx1'
  collection 'jmxcollection'
  ds_name 'jmx-ds-name'
  friendly_name 'jmx-friendly-name'
end

opennms_jmx_mbean 'org.apache.activemq.Queue' do
  collection_name 'jmxcollection'
  objectname 'org.apache.activemq:BrokerName=msgbroker-a.pe.spanlink.com,Type=Queue,Destination=splk.sw'
  attribs(
    'ConsumerCount' => { 'alias' => '5ConsumerCnt', 'type' => 'gauge' },
    'InFlightCount' => { 'alias' => '5InFlightCnt', 'type' => 'gauge' }
  )
end

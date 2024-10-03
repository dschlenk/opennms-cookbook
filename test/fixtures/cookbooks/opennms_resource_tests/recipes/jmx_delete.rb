include_recipe 'opennms_resource_tests::jmx'
opennms_jmx_collection_service 'jmx_url_ignore_path' do
  package_name 'jmx1'
  collection 'jmxcollection'
  action :delete
end

opennms_jmx_mbean 'delete anotherQueue org.apache.activemq.Queue' do
  mbean_name 'org.apache.activemq.Queue'
  collection_name 'jmxcollection'
  objectname 'org.apache.activemq:BrokerName=broker.example.com,Type=Queue,Destination=anotherQueue'
  action :delete
end

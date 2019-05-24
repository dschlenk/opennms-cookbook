# frozen_string_literal: true
control 'jmx_delete' do
  describe jmx_collection_service('jmx_url_ignore_path', 'jmxcollection', 'jmx1') do
    it { should_not exist }
  end

  describe jmx_mbean('org.apache.activemq.Queue', 'jmxcollection', 'org.apache.activemq:BrokerName=broker.example.com,Type=Queue,Destination=anotherQueue') do
    it { should_not exist }
  end
end

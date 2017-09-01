# frozen_string_literal: true
control 'collection_service' do
  describe collection_service('JSON', 'foo') do
    its('collection') { should eq 'baz' }
    its('class_name') { should eq 'org.opennms.protocols.xml.collector.XmlCollector' }
    its('interval') { should eq 400_000 }
    its('user_defined') { should eq true }
    its('status') { should eq 'off' }
    its('time_out') { should eq 5000 }
    its('retry_count') { should eq 10 }
    its('port') { should eq 1161 }
    its('params') { should eq 'handler-class' => 'org.opennms.protocols.json.collector.DefaultJsonCollectionHandler' }
    its('thresholding_enabled') { should eq true }
  end

  describe collection_service('JSON-bar', 'bar') do
    its('collection') { should eq 'default' }
    its('class_name') { should eq 'org.opennms.protocols.xml.collector.XmlCollector' }
    its('params') { should eq 'handler-class' => 'org.opennms.protocols.json.collector.DefaultJsonCollectionHandler' }
  end
end

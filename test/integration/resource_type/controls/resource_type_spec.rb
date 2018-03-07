# frozen_string_literal, tru
control 'resource_type' do
  describe resource_type('wibbleWobble', 'metasyntactic') do
    it { should exist }
    its('label') { should eq 'Wibble Wobble' }
    its('resource_label') { should eq '${wibble} - ${wobble}' }
    its('persistence_selector_strategy') { should eq 'org.opennms.netmgt.collectd.PersistRegexSelectorStrategy' }
    its('persistence_selector_strategy_params') { should eq [{ 'theKey' => 'theValue' }] }
    its('storage_strategy') { should eq 'org.opennms.netmgt.dao.support.SiblingColumnStorageStrategy' }
    its('storage_strategy_params') { should eq [{ 'theKey' => 'theValue' }] }
  end

  describe resource_type('wibbleWobble', 'garbage') do
    it { should_not exist }
  end

  describe resource_type('wobbleWibble', 'metasyntactic') do
    it { should exist }
    its('label') { should eq 'Wobble Wibble' }
    its('resource_label') { should eq '${wobble} - ${wibble}' }
    its('persistence_selector_strategy') { should eq 'org.opennms.netmgt.collection.support.PersistAllSelectorStrategy' }
    its('storage_strategy') { should eq 'org.opennms.netmgt.collection.support.IndexStorageStrategy' }
  end
end

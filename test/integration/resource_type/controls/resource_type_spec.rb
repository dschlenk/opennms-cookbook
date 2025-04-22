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

  describe resource_type('wobbleWibble', 'metasyntactic') do
    it { should exist }
    its('label') { should eq 'Wobble Wibble' }
    its('resource_label') { should eq '${wobble} - ${wibble}' }
    its('persistence_selector_strategy') { should eq 'org.opennms.netmgt.collection.support.PersistAllSelectorStrategy' }
    its('storage_strategy') { should eq 'org.opennms.netmgt.collection.support.IndexStorageStrategy' }
  end

  describe resource_type('newerType', nil, 'newer-type.xml') do
    it { should exist }
    its('label') { should eq 'Newer Type' }
    its('resource_label') { should eq '${type} - ${name}' }
    its('persistence_selector_strategy') { should eq 'org.opennms.netmgt.collectd.PersistRegexSelectorStrategy' }
    its('persistence_selector_strategy_params') { should eq [{ 'theKey' => 'theValue' }] }
    its('storage_strategy') { should eq 'org.opennms.netmgt.dao.support.SiblingColumnStorageStrategy' }
    its('storage_strategy_params') { should eq [{ 'theKey' => 'theValue' }] }
  end

  describe resource_type('wmiW3', 'wmi') do
    it { should_not exist }
  end

  describe resource_type('wmiCollector', nil, 'wmi-collector.xml') do
    it { should_not exist }
  end

  describe resource_type('drsPSUIndex', 'dell') do
    it { should exist }
    its('label') { should eq 'Dell DRAC Power Supply Unit' }
    its('resource_label') { should eq 'Location: ${drsPSULocation}' }
    its('persistence_selector_strategy') { should eq 'org.opennms.netmgt.collectd.PersistRegexSelectorStrategy' }
    its('persistence_selector_strategy_params') { should eq [{ 'theKey' => 'theValue' }] }
    its('storage_strategy') { should eq 'org.opennms.netmgt.dao.support.SiblingColumnStorageStrategy' }
    its('storage_strategy_params') { should eq [{ 'theKey' => 'theValue' }] }
  end

  describe resource_type('pgTableSpace', nil, 'postgresql-resource.xml') do
    it { should exist }
    its('label') { should eq 'PG Tablespace' }
    its('resource_label') { should eq 'space ${spcname}' }
    its('persistence_selector_strategy') { should eq 'org.opennms.netmgt.collectd.PersistRegexSelectorStrategy' }
    its('persistence_selector_strategy_params') { should eq [{ 'theKey' => 'theValue' }] }
    its('storage_strategy') { should eq 'org.opennms.netmgt.dao.support.SiblingColumnStorageStrategy' }
    its('storage_strategy_params') { should eq [{ 'theKey' => 'theValue' }] }
  end

  describe resource_type('create_if_missing', 'metasyntactic') do
    it { should exist }
    its('label') { should eq 'Create If Missing' }
    its('resource_label') { should eq '${resource} (index:${index})' }
  end

  describe resource_type('noop_create_if_missing', 'metasyntactic') do
    it { should_not exist }
  end

  describe resource_type('hrStorageIndex', 'mib2') do
    it { should exist }
    its('label') { should eq 'Storage (SNMP MIB-2 Host Resources)' }
    its('resource_label') { should eq '${hrStorageDescr}' }
    its('persistence_selector_strategy') { should eq 'org.opennms.netmgt.collection.support.PersistAllSelectorStrategy' }
    its('storage_strategy') { should eq 'org.opennms.netmgt.dao.support.SiblingColumnStorageStrategy' }
    its('storage_strategy_params') { should eq [{ 'sibling-column-name' => 'hrStorageDescr' }, { 'replace-first' => 's/^-$/_root_fs/' }, { 'replace-all' => 's/^-//' }, { 'replace-all' => 's/\s//' }, { 'replace-all' => 's/:\\\\.*//' }] }
  end

  describe resource_type('diskIOIndex', 'netsnmp') do
    it { should exist }
    its('label') { should eq 'Disk IO (UCD-SNMP MIB)' }
    its('resource_label') { should eq '${diskIODevice} (index ${index})' }
    its('persistence_selector_strategy') { should eq 'org.opennms.netmgt.collectd.PersistRegexSelectorStrategy' }
    its('persistence_selector_strategy_params') { should eq [{ 'match-expression' => "not(#diskIODevice matches '^(loop|ram).*')" }] }
    its('storage_strategy') { should eq 'org.opennms.netmgt.dao.support.SiblingColumnStorageStrategy' }
    its('storage_strategy_params') { should eq [{ 'sibling-column-name' => 'diskIODevice' }, { 'replace-all' => 's/^-//' }, { 'replace-all' => 's/\s//' }, { 'replace-all' => 's/:\\\\.*//' }] }
  end

  describe resource_type('dskIndex', 'netsnmp') do
    it { should exist }
    its('label') { should eq 'Disk Table Index (UCD-SNMP MIB)' }
    its('resource_label') { should eq '${ns-dskPath} (index ${index})' }
    its('persistence_selector_strategy') { should eq 'org.opennms.netmgt.collection.support.PersistAllSelectorStrategy' }
    its('storage_strategy') { should eq 'org.opennms.netmgt.dao.support.SiblingColumnStorageStrategy' }
    its('storage_strategy_params') { should eq [{ 'sibling-column-name' => 'ns-dskPath' }, { 'replace-first' => 's/^-$/_root_fs/' }, { 'replace-all' => 's/^-//' }, { 'replace-all' => 's/\s//' }, { 'replace-all' => 's/:\\\\.*//' }] }
  end
end

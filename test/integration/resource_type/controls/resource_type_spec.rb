control 'resource_type' do
  # The file_name resources of this suite queue a delayed restart of the
  # opennms service at the end of converge, and the restarted webapp takes
  # a while until it serves again; wait for it before the group-based
  # lookups below query the v2 REST API. The http resource returns a nil
  # status while the webapp does not answer, and a real status as soon as
  # it answers at all (pre-36 answers without a v2 API and needs no
  # wait), so only nil statuses, i.e. the boot window, are retried. The
  # 900s deadline covers the slowest observed boot on slow or emulated
  # hardware (about 9 minutes); on regular hardware the wait ends as soon
  # as the webapp serves
  api = 'http://localhost:8980/opennms/api/v2/datacollectionconf/collectsources/names-and-ids'
  deadline = Time.now + 900
  loop do
    begin
      status = inspec.http(api, auth: { user: 'admin', pass: 'admin' }, open_timeout: 5, read_timeout: 30).status
    rescue StandardError
      status = nil
    end
    break unless status.nil?
    break if Time.now >= deadline
    sleep 5
  end

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

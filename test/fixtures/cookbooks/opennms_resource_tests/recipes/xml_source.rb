# all options
include_recipe 'opennms_resource_tests::xml_collection'
opennms_xml_source 'http://{ipaddr}/get-example' do
  collection_name 'foo'
  request_method 'GET'
  request_params 'timeout' => '6000', 'retries' => '2'
  request_headers 'User-Agent' => 'HotJava/1.1.2 FCS'
  request_content "<person>\n<firstName>Alejandro</firstName>\n<lastName>Galue</lastName>\n</person>"
  import_groups ['mygroups.xml']
end

# minimal
opennms_xml_source 'http://{ipaddr}/get-minimal' do
  collection_name 'foo'
end

# use url attribute
opennms_xml_source 'something to delete' do
  url 'http://{ipaddr}/to-delete'
  collection_name 'foo'
end

# externally sourced import groups
opennms_xml_source 'netapp-snapmirror' do
  collection_name 'foo'
  url 'http://192.168.64.2/snapmirror.xml'
  import_groups ['netapp-snapmirror-stats.xml']
  import_groups_source 'https://raw.githubusercontent.com/opennms-config-modules/netapp-snapmirror/74877429c168c9db1e0fe96db2ecc5960274031d/xml-datacollection'
end

# remove the OOTB resource
opennms_xml_source 'modify OOTB source' do
  url 'http://{ipaddr}:9200/_cluster/stats'
  collection_name 'xml-elasticsearch-cluster-stats'
  import_groups ['elasticsearch-cluster-stats.xml', 'more-elasticsearch-cluster-stats.xml']
  import_groups_source 'cookbook_file'
  action :update
end

# something with groups
opennms_xml_source 'sftp.3gpp://opennms:Op3nNMS!@{ipaddr}/opt/3gpp/data/?step={step}&amp;neId={foreignId}' do
  collection_name 'foo'
  groups [
    { 'name' => 'platform-system-resource',
      'resource_type' => 'platformSystemResource',
      'key_xpath' => '@measObjLdn',
      'resource_xpath' => "/measCollecFile/measData/measInfo[@measInfoId='platform-system|resource']/measValue",
      'timestamp_xpath' => '/measCollecFile/fileFooter/measCollec/@endTime',
      'timestamp_format' => "yyyy-MM-dd'T'HH:mm:ssZ",
      'objects' => [
        { 'name' => 'cpuUtilization', 'type' => 'gauge', 'xpath' => 'r[@p=1]' },
        { 'name' => 'memUtilization', 'type' => 'gauge', 'xpath' => 'r[@p=2]' },
        { 'name' => 'suspect', 'type' => 'string', 'xpath' => 'suspect' },
      ],
    },
  ]
end

# something with groups that has resource keys
opennms_xml_source 'http://{ipaddr}/rpc' do
  collection_name 'foo'
  groups [
    { 'name' => 'rpc-reply', 'resource_type' => 'cfmEntry', 'resource_xpath' => '/rpc-reply/cfm-iterator-statistics/cfm-entry',
      'resource_keys' => ['cfm-iter-mep-summary/cfm-maintenance-domain-name', 'cfm-iter-mep-summary/cfm-maintenance-association-name'],
      'objects' => [
        { 'name' => 'V01', 'type' => 'GAUGE', 'xpath' => 'cfm-iter-ethlm-entry/cfm-lmm-sent' },
        { 'name' => 'V02', 'type' => 'GAUGE', 'xpath' => 'cfm-iter-ethlm-entry/cfm-lmm-skipped-for-threshold-hit' },
        { 'name' => 'V03', 'type' => 'GAUGE', 'xpath' => 'cfm-iter-ethlm-entry/cfm-lmm-skipped-for-threshold-hit-window' },
        { 'name' => 'V04', 'type' => 'GAUGE', 'xpath' => 'cfm-iter-ethlm-entry/cfm-lmr-received' },
        { 'name' => 'V05', 'type' => 'GAUGE', 'xpath' => 'cfm-iter-ethlm-entry/cfm-lmr-out-of-seq' },
        { 'name' => 'V06', 'type' => 'GAUGE', 'xpath' => 'cfm-iter-ethlm-entry/cfm-lmr-fc-mismatch' },
        { 'name' => 'V07', 'type' => 'GAUGE', 'xpath' => 'cfm-iter-ethlm-entry/cfm-accu-tx-near-end-cir-loss-stats' },
        { 'name' => 'V08', 'type' => 'GAUGE', 'xpath' => 'cfm-iter-ethlm-entry/cfm-accu-tx-far-end-cir-loss-stats' },
        { 'name' => 'V09', 'type' => 'GAUGE', 'xpath' => 'cfm-iter-ethlm-entry/cfm-accu-tx-near-end-eir-loss-stats' },
        { 'name' => 'V10', 'type' => 'GAUGE', 'xpath' => 'cfm-iter-ethlm-entry/cfm-accu-tx-far-end-eir-loss-stats' },
        { 'name' => 'V11', 'type' => 'GAUGE', 'xpath' => 'cfm-iter-ethlm-entry/cfm-accu-loss-near-end-cir-loss-stats' },
        { 'name' => 'V12', 'type' => 'GAUGE', 'xpath' => 'cfm-iter-ethlm-entry/cfm-accu-loss-near-end-cir-loss-stats-percent' },
        { 'name' => 'V13', 'type' => 'GAUGE', 'xpath' => 'cfm-iter-ethlm-entry/cfm-accu-loss-far-end-cir-loss-stats' },
        { 'name' => 'V14', 'type' => 'GAUGE', 'xpath' => 'cfm-iter-ethlm-entry/cfm-accu-loss-far-end-cir-loss-stats-percent' },
        { 'name' => 'V15', 'type' => 'GAUGE', 'xpath' => 'cfm-iter-ethlm-entry/cfm-accu-loss-near-end-eir-loss-stats' },
        { 'name' => 'V16', 'type' => 'GAUGE', 'xpath' => 'cfm-iter-ethlm-entry/cfm-accu-loss-near-end-eir-loss-stats-percent' },
        { 'name' => 'V17', 'type' => 'GAUGE', 'xpath' => 'cfm-iter-ethlm-entry/cfm-accu-loss-far-end-eir-loss-stats' },
        { 'name' => 'V18', 'type' => 'GAUGE', 'xpath' => 'cfm-iter-ethlm-entry/cfm-accu-loss-far-end-eir-loss-stats-percent' },
        { 'name' => 'V19', 'type' => 'GAUGE', 'xpath' => 'cfm-iter-ethlm-entry/cfm-last-measured-near-end-cir-loss-stats' },
        { 'name' => 'V20', 'type' => 'GAUGE', 'xpath' => 'cfm-iter-ethlm-entry/cfm-last-measured-far-end-cir-loss-stats' },
        { 'name' => 'V21', 'type' => 'GAUGE', 'xpath' => 'cfm-iter-ethlm-entry/cfm-last-measured-near-end-eir-loss-stats' },
        { 'name' => 'V22', 'type' => 'GAUGE', 'xpath' => 'cfm-iter-ethlm-entry/cfm-last-measured-far-end-eir-loss-stats' },
      ]
    }
  ]
end

opennms_xml_source 'create-if-missing' do
  url http://192.168.64.2/snapmirror.xml
  collection_name 'foo'
  action :create_if_missing
end

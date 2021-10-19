# frozen_string_literal: true
source 'https://supermarket.chef.io'

metadata

group :integration do
  cookbook 'postgresql', '~> 7.1.5'
  cookbook 'yum-centos-ct', path: 'test/fixtures/cookbooks/yum-centos-ct'
  cookbook 'yum-epel'
  cookbook 'onms_lwrp_test', path: 'test/fixtures/cookbooks/onms_lwrp_test'
  cookbook 'oracle_java8', path: 'test/fixtures/cookbooks/oracle_java8'
  cookbook 'openjdk_java11', path: 'test/fixtures/cookbooks/openjdk_java11'
  cookbook 'opennms-elasticsearch', path: 'test/fixtures/cookbooks/opennms-elasticsearch'
  cookbook 'opennms_helm'
  cookbook 'snmp', path: 'test/fixtures/cookbooks/snmp'
  cookbook 'hsflowd', path: 'test/fixtures/cookbooks/hsflowd'
  cookbook 'lecert', path: 'test/fixtures/cookbooks/lecert'
end

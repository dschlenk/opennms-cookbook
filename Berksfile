# frozen_string_literal: true
source 'https://supermarket.chef.io'

metadata
group :integration do
  cookbook 'yum-centos'
  cookbook 'yum-epel'
  cookbook 'postgresql', '>= 3.4.20'
  cookbook 'onms_lwrp_test', path: 'test/fixtures/cookbooks/onms_lwrp_test'
  cookbook 'oracle_java8', path: 'test/fixtures/cookbooks/oracle_java8'
end

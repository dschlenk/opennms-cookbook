# frozen_string_literal: true
source 'https://supermarket.chef.io'

metadata
group :integration do
  cookbook 'postgresql', git: 'https://github.com/dschlenk/postgresql.git', branch: 'release/6.1.2'
  cookbook 'yum-centos'
  cookbook 'yum-epel'
  cookbook 'onms_lwrp_test', path: 'test/fixtures/cookbooks/onms_lwrp_test'
  cookbook 'oracle_java8', path: 'test/fixtures/cookbooks/oracle_java8'
end

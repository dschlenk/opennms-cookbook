source 'https://api.berkshelf.com'

metadata
cookbook 'grafana', git: 'https://github.com/dschlenk/chef-grafana'

group :integration do
  cookbook 'yum-centos'
  cookbook 'yum-epel'
  cookbook 'postgresql', '>= 3.4.20'
  cookbook 'onms_lwrp_test', path: 'test/fixtures/cookbooks/onms_lwrp_test'
end

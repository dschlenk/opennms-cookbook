#
# Cookbook Name:: opennms-cookbook
# Recipe:: grafana
#
# Copyright (c) 2016 ConvergeOne Holding Corp.
#
# License: Apache 2.0

require 'digest'
node.default['grafana']['install_type'] = 'package'
node.default['grafana']['version'] = '3.1.0-1468321182'
node.default['grafana']['package']['version'] = '3.1.0-1468321182'
node.default['grafana']['webserver'] = ''

include_recipe 'grafana::default'

execute 'install opennms plugin' do
  command '/usr/sbin/grafana-cli plugins install opennms-datasource'
  not_if '/usr/sbin/grafana-cli plugins ls | grep -q opennms-datasource'
  notifies :restart, 'service[grafana-server]'
end

log 'start OpenNMS' do
  notifies :start, 'service[opennms]', :immediately
end

node.default_unless['grafana']['opennms_datasource']['password'] = random_password
pwhash = Digest::MD5.hexdigest(node['grafana']['opennms_datasource']['password']).upcase
opennms_user 'grafana' do
  password pwhash
end

grafana_datasource 'OpenNMS (local)' do
  datasource(
    type: 'opennms-datasource',
    url: "http://localhost:#{node['opennms']['properties']['jetty']['port']}/opennms",
    access: 'proxy',
    basicAuth: true,
    basicAuthPassword: node['grafana']['opennms_datasource']['password'],
    basicAuthUser: 'grafana',
    isDefault: true,
    withCredentials: true
  )
end

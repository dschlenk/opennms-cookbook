#
# Cookbook Name:: opennms-cookbook
# Recipe:: grafana
#
# Copyright (c) 2016 ConvergeOne Holding Corp.
#
# License: Apache 2.0

require 'digest'
require 'rest-client'

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

node.default_unless['grafana']['opennms_datasource']['password'] = random_password
pwhash = Digest::MD5.hexdigest(node['grafana']['opennms_datasource']['password']).upcase

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

ruby_block 'create API key for OpenNMS' do
  block do
    require 'rest-client'
    begin
    response = RestClient::Request.new(
      method: :post,
      url: 'http://localhost:3000/api/auth/keys',
      user: 'admin',
      password: 'admin',
      headers: { :accept => :json,
      content_type: :json },
      payload: '{"role":"Viewer","name":"OpenNMS"}'
    ).execute
    results = JSON.parse(response.to_str)
    Chef::Log.debug " results: #{results} key: #{results['key']}"
    node.override['opennms']['properties']['grafana']['api_key'] = results['key']
    node.override['opennms']['properties']['grafana']['show'] = true
    rescue => e
      Chef::Log.warn e.response
    end
  end
  notifies :create, "template[#{node['opennms']['conf']['home']}/etc/opennms.properties]", :immediately
  only_if { node['opennms']['properties']['grafana']['api_key'] == '' }
end

# required to add user via ReST
log 'start OpenNMS' do
  notifies :start, 'service[opennms]', :immediately
end

opennms_user 'grafana' do
  password pwhash
end

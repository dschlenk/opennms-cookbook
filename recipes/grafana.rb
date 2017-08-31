# frozen_string_literal: true
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
node.override['opennms']['properties']['grafana']['show'] = true

include_recipe 'grafana::default'

execute 'install opennms plugin' do
  command '/usr/sbin/grafana-cli plugins install opennms-datasource'
  not_if '/usr/sbin/grafana-cli plugins ls | grep -q opennms-datasource'
  notifies :update, 'grafana_user[admin]', :immediately
end

node.normal_unless['grafana']['opennms_datasource']['password'] = random_password
pwhash = Digest::MD5.hexdigest(node['grafana']['opennms_datasource']['password']).upcase

# generate now when necessary, for possible use later
adminpw = random_password
# maybe it's hardcoded or already exists
if node['grafana'].key?('users') && node['grafana']['users'].key?('admin') && !node['grafana']['users']['admin']['password'].nil?
  adminpw = node['grafana']['users']['admin']['password']
end

ruby_block 'save admin password' do
  block do
    node.normal['grafana']['users']['admin']['password'] = adminpw
  end
  action :nothing
end

grafana_user 'admin' do
  admin_user 'admin'
  admin_password 'admin'
  user(
    lazy do
      {
        login: 'admin',
        password: adminpw,
      }
    end
  )
  action :nothing
  notifies :run, 'ruby_block[save admin password]', :immediately
end

grafana_datasource 'OpenNMS (local)' do
  admin_user 'admin'
  admin_password lazy { node['grafana']['users']['admin']['password'] }
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
    Opennms::Grafana.create_api_key(node)
  end
  notifies :create, "template[#{node['opennms']['conf']['home']}/etc/opennms.properties]", :immediately
  notifies :create, 'file[grafana api key]', :immediately if Opennms::Helpers.major(node['opennms']['version']).to_i >= 18
  not_if do
    Opennms::Grafana.api_key?(node)
  end
end

file 'grafana api key' do
  path "#{node['opennms']['conf']['home']}/etc/opennms.properties.d/grafana.properties"
  content lazy { "org.opennms.grafanaBox.apiKey=#{node['opennms']['properties']['grafana']['api_key']}\n" }
  owner 'root'
  group 'root'
  mode 00664
  action :nothing
end

# required to add user via ReST
log 'start OpenNMS' do
  notifies :start, 'service[opennms]', :immediately
end

opennms_user 'grafana' do
  password pwhash
end

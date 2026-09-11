#
# Cookbook:: opennms
# Recipe:: templates
#
# Copyright:: 2015-2024, ConvergeOne Holding Corp
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
onms_home = node['opennms']['conf']['home']
onms_home ||= '/opt/opennms'

node.default['opennms']['datacollection']['default']['ref_cpq_im'] = true
node.default['opennms']['datacollection']['default']['ref_mib2_if'] = true
node.default['opennms']['datacollection']['default']['ref_mib2_pe'] = true

pw = opennms_scv_password

# In Horizon 34+ the installer reads opennms.properties.d, so the SCV key only needs to be set via properties file.
unless pw.nil?
  node.default['opennms']['properties']['files']['scv'] = { 'org.opennms.features.scv.jceks.key' => pw }
end

template "#{onms_home}/etc/opennms.conf" do
  cookbook node['opennms']['conf']['cookbook']
  source 'opennms.conf.erb'
  mode '664'
  owner node['opennms']['username']
  group node['opennms']['groupname']
  notifies :restart, 'service[opennms]' if opennms_running?
  sensitive true
  variables(
    env: node['opennms']['conf']['env']
  )
end

node['opennms']['properties']['files'].each do |file, properties|
  file "#{onms_home}/etc/opennms.properties.d/#{file}.properties" do
    owner node['opennms']['username']
    group node['opennms']['groupname']
    mode '0600'
    content properties.map { |k, v| "#{k}=#{v}" }.join("\n")
    notifies :restart, 'service[opennms]' if opennms_running?
  end
end

node['opennms']['features_boot']['files'].each do |file, feature|
  file "#{onms_home}/etc/featuresBoot.d/#{file}.boot" do
    owner node['opennms']['username']
    group node['opennms']['groupname']
    mode '0644'
    content "#{feature}\n"
    notifies :restart, 'service[opennms]' if opennms_running?
  end
end

opennms_secret 'opennms postgresql user' do
  secret_alias 'postgres'
  username node['opennms']['username']
  password chef_vault_item(node['opennms']['postgresql']['user_vault'], node['opennms']['postgresql']['user_vault_item'])['opennms']['password']
end

opennms_secret 'postgres postgresql user' do
  secret_alias 'postgres-admin'
  username 'postgres'
  password chef_vault_item(node['opennms']['postgresql']['user_vault'], node['opennms']['postgresql']['user_vault_item'])['postgres']['password']
end

template "#{onms_home}/etc/opennms-datasources.xml" do
  cookbook node['opennms']['datasources_cookbook']
  source 'opennms-datasources.xml.erb'
  mode '664'
  owner node['opennms']['username']
  group node['opennms']['groupname']
  notifies :restart, 'service[opennms]' if opennms_running?
  variables(
    datasources: node['opennms']['datasources']
  )
end

template "#{onms_home}/etc/rrd-configuration.properties" do
  cookbook 'opennms'
  source 'rrd-configuration.properties.erb'
  mode '0664'
  owner node['opennms']['username']
  group node['opennms']['groupname']
  notifies :restart, 'service[opennms]' if opennms_running?
  variables(
    strategy_class: node['opennms']['rrd']['strategy_class'],
    interface_jar: node['opennms']['rrd']['interface_jar'],
    jrrd: node['opennms']['rrd']['jrrd'],
    queue: node['opennms']['rrd']['queue'],
    jrobin: node['opennms']['rrd']['jrobin'],
    usetcp: node['opennms']['rrd']['usetcp'],
    tcp: node['opennms']['rrd']['tcp']
  )
end

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

# this has to go in both `opennms.conf` the properties file because the installer includes this file but not `opennms.properties.*`.
unless pw.nil?
  node.default['opennms']['conf']['env']['ADDITIONAL_MANAGER_OPTIONS'] = "${ADDITIONAL_MANAGER_OPTIONS} -Dorg.opennms.features.scv.jceks.key=#{pw}"
  node.default['opennms']['properties']['files']['scv'] = { 'org.opennms.features.scv.jceks.key' => pw }
end

template "#{onms_home}/etc/opennms.conf" do
  cookbook node['opennms']['conf']['cookbook']
  source 'opennms.conf.erb'
  mode '664'
  owner node['opennms']['username']
  group node['opennms']['groupname']
  notifies :restart, 'service[opennms]'
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
  variables(
    datasources: node['opennms']['datasources']
  )
end

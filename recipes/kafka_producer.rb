#
# Cookbook:: opennms
# Recipe:: kafka_producer
#
# Copyright:: 2025, ConvergeOne Holding Corp.
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

template "#{onms_home}/etc/org.opennms.features.kafka.producer.cfg" do
  source 'org.opennms.features.kafka.producer.cfg.erb'
  owner node['opennms']['username']
  group node['opennms']['groupname']
  mode '0664'
  variables('producer_configs' => node['opennms']['kafka']['producer']['config'])
  notifies :restart, 'service[opennms]', :delayed
end

# Since client properties often contain secrets, best practice is to populate the producer_client run_state variable elsewhere in your run_list from a secure source like a Chef vault.
# For use cases that don't require secrets, node attributes can be used.
ruby_block 'set producer_client during execute' do
  block do
    node.run_state['opennms']['kafka'] = { 'producer_client' => node['opennms']['kafka']['producer_client'] } if node.run_state['opennms']['kafka'].nil? || node.run_state['opennms']['kafka']['producer_client'].nil?
  end
end

template "#{onms_home}/etc/org.opennms.features.kafka.producer.client.cfg" do
  source 'org.opennms.features.kafka.producer.client.cfg.erb'
  owner node['opennms']['username']
  group node['opennms']['groupname']
  mode '0600'
  variables(lazy { { 'client_configs' => node.run_state['opennms']['kafka']['producer_client'] } })
  notifies :restart, 'service[opennms]', :delayed
end

node.default['opennms']['features_boot']['files']['kafka_producer'] = 'opennms-kafka-producer'

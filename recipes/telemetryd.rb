# frozen_string_literal: true
#
# Cookbook:: opennms-cookbook
# Recipe:: telemetryd
# Enables all the OOTB telemetryd protocols and allows further customization of telemetryd
# via template. See hash format required for additional protocols in attributes/default.rb
# Copyright:: 2018, ConvergeOne
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
#

mv = Opennms::Helpers.major(node['opennms']['version'])
template_dir = if node['opennms']['conf']['cookbook'] == 'opennms'
                 "horizon-#{format(mv, version: node['opennms']['version'])}/"
               else
                 ''
               end
# configure elasticsearch credentials
# TODO: move this to a standalone es recipe when event/alarm forwarding implemented
# TODO: find out if this actually requires a restart
# node['opennms']['es']['hosts'] must be defined in a wrapper or role, like:
# default['opennms']['es']['hosts'] = {
#   'http://localhost:9200' => { 'username' => 'ulf', 'password' => 'ulf' }
# }
template "#{node['opennms']['conf']['home']}/etc/elastic-credentials.xml" do
  source "#{template_dir}elastic-credentials.xml.erb"
  owner 'root'
  group 'root'
  mode '664'
  notifies :restart, 'service[opennms]'
  variables(
    hosts: node['opennms']['es']['hosts']
  )
end

# configure elasticsearch persistence for flows
# For this to work you have to specify some node attributes in your wrapper or role.
# At a minimum, node['opennms']['es']['flows'] must have a 'url' key/value.
# You can also specify any of the valid key/value pairs from
# https://docs.opennms.org/opennms/releases/22.0.0/guide-admin/guide-admin.html#_credentials
# like:
# default['opennms']['es']['flows']['elasticIndexStrategy'] = 'hourly'
template "#{node['opennms']['conf']['home']}/etc/org.opennms.features.flows.persistence.elastic.cfg" do
  source "#{template_dir}org.opennms.features.flows.persistence.elastic.cfg.erb"
  owner 'root'
  group 'root'
  mode '664'
  variables(
    elastic: node['opennms']['es']['flows']['persistence']
  )
  only_if { mv.to_i >= 22 }
  only_if { node['opennms'].key?('es') && node['opennms']['es'].key?('flows') && node['opennms']['es']['flows'].key?('persistence') && node['opennms']['es']['flows']['persistence'].key?('url') }
  notifies :create, "template[#{node['opennms']['conf']['home']}/etc/telemetryd-configuration.xml]", :immediately
  notifies :create, "template[#{node['opennms']['conf']['home']}/etc/org.opennms.netmgt.flows.rest.cfg]", :immediately
end

# turn on the listeners / adapters
template "#{node['opennms']['conf']['home']}/etc/telemetryd-configuration.xml" do
  cookbook node['opennms']['telemetryd']['cookbook']
  source "#{template_dir}telemetryd-configuration.xml.erb"
  owner 'root'
  group 'root'
  mode '664'
  notifies :run, 'opennms_send_event[restart_Telemetryd]'
  variables(
    telemetryd: node['opennms']['telemetryd']
  )
  action :nothing
end

# configure grafana/helm
template "#{node['opennms']['conf']['home']}/etc/org.opennms.netmgt.flows.rest.cfg" do
  source "#{template_dir}org.opennms.netmgt.flows.rest.cfg.erb"
  owner 'root'
  group 'root'
  mode '664'
  variables(
    grafana_host: node['opennms']['properties']['grafana']['hostname'],
    grafana_port: node['opennms']['properties']['grafana']['port'],
    grafana_protocol: node['opennms']['properties']['grafana']['protocol']
  )
  action :nothing
end

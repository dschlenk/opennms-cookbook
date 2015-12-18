#
# Cookbook Name:: opennms
# Recipe:: default
#
# Copyright 2014, Spanlink Communications, Inc
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

include_recipe 'build-essential::default'
chef_gem 'java_properties' do
  compile_time true
end
chef_gem 'rest-client' do
  compile_time true
end

chef_gem 'addressable' do
  compile_time true
end

fqdn = node[:fqdn]
fqdn ||= node[:hostname]

onms_home = node[:opennms][:conf][:home]
onms_home ||= '/opt/opennms'

hostsfile_entry node['ipaddress'] do
  hostname fqdn
  action [:create_if_missing, :append]
end

include_recipe 'opennms::packages'
include_recipe 'opennms::send_events'

if node['opennms']['upgrade']
  include_recipe 'opennms::upgrade'
end

execute "runjava" do
  cwd onms_home
  creates "#{onms_home}/etc/java.conf"
  command "#{onms_home}/bin/runjava -s"
end

execute "install" do
  cwd onms_home
  creates "#{onms_home}/etc/configured"
  command "#{onms_home}/bin/install -dis"
end

include_recipe 'opennms::base_templates'
include_recipe 'opennms::templates'

service "opennms" do
  supports :status => true, :restart => true
  action [ :enable]#, :start ]
end

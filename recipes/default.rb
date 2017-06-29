# frozen_string_literal: true
#
# Cookbook Name:: opennms
# Recipe:: default
#
# Copyright 2014-2016, ConvergeOne Holdings Corp.
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
%w(java_properties rest-client addressable).each do |g|
  chef_gem g do
    compile_time true
  end
end

fqdn = node['fqdn']
fqdn ||= node['hostname']

onms_home = node['opennms']['conf']['home']
onms_home ||= '/opt/opennms'

hostsfile_entry node['ipaddress'] do
  hostname fqdn
  action [:create_if_missing, :append]
end

include_recipe 'opennms::packages'
include_recipe 'opennms::send_events'
include_recipe 'opennms::upgrade' if node['opennms']['upgrade']

execute 'runjava' do
  cwd onms_home
  creates "#{onms_home}/etc/java.conf"
  command "#{onms_home}/bin/runjava -s"
end

execute 'install' do
  cwd onms_home
  creates "#{onms_home}/etc/configured"
  command "#{onms_home}/bin/install -dis"
end

# configure base templates before we get started
include_recipe 'opennms::base_templates'

# If you want a random password, just set secure_admin to true.
# If you want to set the admin password yourself, populate
# node['opennms']['users']['admin']['password'] with your password
# and let the cookbook caclulate the hash and set it for you.
unless node['opennms']['secure_admin_password'].nil?
  require 'digest'
  node.default['opennms']['users']['admin']['password'] = node['opennms']['secure_admin_password']
  node.default['opennms']['users']['admin']['pwhash'] = Digest::MD5.hexdigest(node['opennms']['secure_admin_password']).upcase
end
Chef::Log.debug("secure_admin? #{node['opennms']['secure_admin']}; pwhash? #{node['opennms']['users']['admin']['pwhash']}; password? #{node['opennms']['users']['admin']['password']}")
if (node['opennms']['secure_admin'] && node['opennms']['secure_admin_password'].nil?) || (!node['opennms']['secure_admin'] && node['opennms']['users']['admin']['password'] != 'admin')
  include_recipe 'opennms::adminpw'
end

include_recipe 'opennms::templates' if node['opennms']['templates']

service 'opennms' do
  supports status: true, restart: true
  action [:enable]
end

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

include_recipe 'build-essential::default' # ~FC122
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

if node['opennms']['version'] == '26.2.2-1' || node['opennms']['version'].to_i > 26
  node.default['opennms']['users']['admin']['pwhash'] = 'gU2wmSW7k9v1xg4/MrAsaI+VyddBAhJJt4zPX5SGG0BK+qiASGnJsqM8JOug/aEL'
  node.default['opennms']['users']['salted'] = true
end
if node['opennms']['version'].to_i > 18
  node.default['opennms']['properties']['ticket']['skip_create_when_cleared'] = true
  node.default['opennms']['properties']['ticket']['skip_close_when_not_cleared'] = true
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
if (node['opennms']['secure_admin'] && node['opennms']['secure_admin_password'].nil?) || (!node['opennms']['secure_admin'] && node['opennms']['users']['admin']['password'] != 'admin')
  include_recipe 'opennms::adminpw'
end

include_recipe 'opennms::templates' if node['opennms']['templates']

if node['platform_family'] == 'rhel' && node['platform_version'].to_i > 6
  directory '/etc/systemd/system/opennms.service.d' do
    owner 'root'
    group 'root'
    mode 00755
  end

  file '/etc/systemd/system/opennms.service.d/timeout.conf' do
    owner 'root'
    group 'root'
    mode 00644
    content "[Service]\nTimeoutSec=900"
    notifies :run, 'execute[reload systemd]', :immediately
  end
end

service 'opennms' do
  supports status: true, restart: true
  action [:enable]
end

execute 'reload systemd' do
  action :nothing
  command '/usr/bin/systemctl daemon-reload'
end

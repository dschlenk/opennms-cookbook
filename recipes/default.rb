#
# Cookbook:: opennms
# Recipe:: default
#
# Copyright:: 2014-2024, ConvergeOne Holdings Corp.
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

%w(addressable).each do |g|
  chef_gem g
end

fqdn = node['fqdn']
fqdn ||= node['hostname']

hostname fqdn

onms_home = node['opennms']['conf']['home']
onms_home ||= '/opt/opennms'

include_recipe 'opennms::packages'
include_recipe 'opennms::send_events'

if node['opennms']['jre_path'].nil?
  execute 'runjava' do
    user node['opennms']['username']
    cwd onms_home
    creates "#{onms_home}/etc/java.conf"
    command "#{onms_home}/bin/runjava -s"
  end
else
  execute 'runjava' do
    user node['opennms']['username']
    cwd onms_home
    command "#{onms_home}/bin/runjava -S #{node['opennms']['jre_path']}"
  end
end

directory '/etc/systemd/system/opennms.service.d' do
  owner node['opennms']['username']
  group node['opennms']['groupname']
  mode '755'
end

start_timeout = node['opennms']['conf']['env']['START_TIMEOUT'].to_i * 10 + 30
file '/etc/systemd/system/opennms.service.d/timeout.conf' do
  owner 'root'
  group 'root'
  mode '644'
  content "[Service]\nTimeoutSec=#{start_timeout}"
  notifies :run, 'execute[reload systemd]', :immediately
end

# configure base templates before we get started
include_recipe 'opennms::rrdtool' if node['opennms']['rrdtool']['enabled']
include_recipe 'opennms::base_templates'
execute 'install' do
  cwd onms_home
  user node['opennms']['username']
  creates "#{onms_home}/etc/configured"
  command "#{onms_home}/bin/install -dis"
end

service 'opennms' do
  timeout start_timeout
  supports status: true, restart: true
  action [:enable, :start]
end

execute 'reload systemd' do
  action :nothing
  command '/usr/bin/systemctl daemon-reload'
end

include_recipe 'opennms::adminpw'
include_recipe 'opennms::default_resources'
include_recipe 'opennms::templates'

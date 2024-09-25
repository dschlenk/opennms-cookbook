#
# Cookbook:: opennms-cookbook
# Recipe:: postgres
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

cookbook_file "#{Chef::Config['file_cache_path']}/openldap-2.6.6-4.el9.x86_64.rpm" do
  source 'openldap-2.6.6-4.el9.x86_64.rpm'
  notifies :upgrade, 'dnf_package[openldap]', :immediately
end

dnf_package 'openldap' do
  source "#{Chef::Config['file_cache_path']}/openldap-2.6.6-4.el9.x86_64.rpm"
  allow_downgrade true
  action :nothing
end

postgresql_install 'postgres' do
  version node['opennms']['postgresql']['version']
  source 'repo'
  repo_pgdg node['opennms']['postgresql']['setup_repo']
  repo_pgdg_common node['opennms']['postgresql']['setup_repo']
  initdb_encoding 'UTF8'
  action %i(install init_server)
end

postgresql_config 'postgresql-server' do
  version '15'

  server_config({
    'autovacuum' => 'on',
    'checkpoint_timeout' => '15min',
    'shared_preload_libraries' => 'pg_stat_statements',
    'track_activities' => 'on',
    'track_counts' => 'on',
    'vacuum_cost_delay' => 50,
    'max_connections' => 160,
  })

  notifies :restart, 'postgresql_service[postgresql]', :delayed
  action :create
end

%w(127.0.0.1/32 ::1/128).each do |h|
  postgresql_access "postgresql #{h} host access" do
    type 'host'
    database 'all'
    user 'all'
    address h
    auth_method 'scram-sha-256'
  end
end

postgresql_service 'postgresql' do
  action %i(enable start)
end

postgresql_user 'postgres' do
  unencrypted_password chef_vault_item(node['opennms']['postgresql']['user_vault'], node['opennms']['postgresql']['user_vault_item'])['postgres']['password']
  action :set_password
end

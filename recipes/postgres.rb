# frozen_string_literal: true
#
# Cookbook Name:: opennms
# Recipe:: postgres
#
# Copyright (c) 2016 ConvergeOne Holding Corp.
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
node.default['postgresql']['password']['postgres'] = 'md5c23797e9a303da48b792b4339c426700'
node.default['postgresql']['version'] = '11'
node.default['postgresql']['config']['data_directory'] = '/var/lib/pgsql/11/data'

node.default['postgresql']['config']['autovacuum'] = 'on'
node.default['postgresql']['config']['checkpoint_timeout'] = '15min'
node.default['postgresql']['config']['shared_preload_libraries'] = 'pg_stat_statements'
node.default['postgresql']['config']['track_activities'] = 'on'
node.default['postgresql']['config']['track_counts'] = 'on'
node.default['postgresql']['config']['vacuum_cost_delay'] = 50

# 'mixed' profile fits our needs mostly - but we need a few more concurrent connections
node.default['postgresql']['config_pgtune']['max_connections'] = 160
# size postgresql as if it were limited to 2GB of RAM
node.default['postgresql']['config_pgtune']['total_memory'] = '1961376kB'
node.default['postgresql']['contrib']['extensions'] = %w(pageinspect pg_buffercache pg_freespacemap pgrowlocks pg_stat_statements pgstattuple)

postgresql_repository 'install'

postgresql_server_install 'package' do
  password node['postgresql']['password']['postgres']
  version node['postgresql']['version']
  action [:install, :create]
end

include_recipe 'opennms::config_initdb'
include_recipe 'opennms::config_pgtune'

additional_config = {}
additional_config['autovacuum'] = node['postgresql']['config']['autovacuum'] unless node['postgresql']['config']['autovacuum'].nil?
additional_config['checkpoint_timeout'] = node['postgresql']['config']['checkpoint_timeout'] unless node['postgresql']['config']['checkpoint_timeout'].nil?
additional_config['shared_preload_libraries'] = node['postgresql']['config']['shared_preload_libraries'] unless node['postgresql']['config']['shared_preload_libraries'].nil?
additional_config['track_activities'] = node['postgresql']['config']['track_activities'] unless node['postgresql']['config']['track_activities'].nil?
additional_config['track_counts'] = node['postgresql']['config']['track_counts'] unless node['postgresql']['config']['track_counts'].nil?
additional_config['vacuum_cost_delay'] = node['postgresql']['config']['vacuum_cost_delay'] unless node['postgresql']['config']['vacuum_cost_delay'].nil?
additional_config['max_connections'] = node['postgresql']['config']['max_connections'] unless node['postgresql']['config']['max_connections'].nil?
additional_config['shared_buffers'] = node['postgresql']['config']['shared_buffers'] unless node['postgresql']['config']['shared_buffers'].nil?
additional_config['effective_cache_size'] = node['postgresql']['config']['effective_cache_size'] unless node['postgresql']['config']['effective_cache_size'].nil?
additional_config['work_mem'] = node['postgresql']['config']['work_mem'] unless node['postgresql']['config']['work_mem'].nil?
additional_config['maintenance_work_mem'] = node['postgresql']['config']['maintenance_work_mem'] unless node['postgresql']['config']['maintenance_work_mem'].nil?
additional_config['max_wal_size'] = node['postgresql']['config']['max_wal_size'] unless node['postgresql']['config']['max_wal_size'].nil?
additional_config['checkpoint_completion_target'] = node['postgresql']['config']['checkpoint_completion_target'] unless node['postgresql']['config']['checkpoint_completion_target'].nil?
additional_config['wal_buffers'] = node['postgresql']['config']['wal_buffers'] unless node['postgresql']['config']['wal_buffers'].nil?
additional_config['default_statistics_target'] = node['postgresql']['config']['default_statistics_target'] unless node['postgresql']['config']['default_statistics_target'].nil?
additional_config['lc_messages'] = node['postgresql']['config']['lc_messages'] unless node['postgresql']['config']['lc_messages'].nil?
additional_config['lc_monetary'] = node['postgresql']['config']['lc_monetary'] unless node['postgresql']['config']['lc_monetary'].nil?
additional_config['lc_numeric'] = node['postgresql']['config']['lc_numeric'] unless node['postgresql']['config']['lc_numeric'].nil?
additional_config['lc_time'] = node['postgresql']['config']['lc_time'] unless node['postgresql']['config']['lc_time'].nil?
additional_config['log_timezone'] = node['postgresql']['config']['log_timezone'] unless node['postgresql']['config']['log_timezone'].nil?
additional_config['timezone'] = node['postgresql']['config']['timezone'] unless node['postgresql']['config']['timezone'].nil?
additional_config['default_text_search_config'] = node['postgresql']['config']['default_text_search_config'] unless node['postgresql']['config']['default_text_search_config'].nil?
additional_config['log_destination'] = node['postgresql']['config']['log_destination'] unless node['postgresql']['config']['log_destination'].nil?
additional_config['log_directory'] = node['postgresql']['config']['log_directory'] unless node['postgresql']['config']['log_directory'].nil?
additional_config['log_filename'] = node['postgresql']['config']['log_filename'] unless node['postgresql']['config']['log_filename'].nil?
additional_config['logging_collector'] = node['postgresql']['config']['logging_collector'] unless node['postgresql']['config']['logging_collector'].nil?
additional_config['log_rotation_age'] = node['postgresql']['config']['log_rotation_age'] unless node['postgresql']['config']['log_rotation_age'].nil?
additional_config['log_rotation_size'] = node['postgresql']['config']['log_rotation_size'] unless node['postgresql']['config']['log_rotation_size'].nil?
additional_config['log_truncate_on_rotation'] = node['postgresql']['config']['log_truncate_on_rotation'] unless node['postgresql']['config']['log_truncate_on_rotation'].nil?

postgresql_server_conf 'PostgreSQL Config' do
  version node['postgresql']['version']
  data_directory node['postgresql']['config']['data_directory']
  additional_config additional_config
  notifies :reload, 'service[postgresql]'
end

# Using this to generate a service resource to control
find_resource(:service, 'postgresql') do
  extend PostgresqlCookbook::Helpers
  service_name lazy { platform_service_name }
  supports restart: true, status: true, reload: true
  action [:enable, :start]
end

if node['platform_family'] == 'rhel'
  package 'postgresql11-contrib'
else
  package 'postgresql-contrib'
end

# Install  extensions
node['postgresql']['contrib']['extensions'].each { |extension|
  postgresql_extension "postgres #{extension}" do
    database 'postgres'
    version node['postgresql']['version']
    extension extension
    notifies :reload, 'service[postgresql]'
  end
}

service 'postgresql-11' do
  action :reload
end

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
node.default['postgresql']['enable_pgdg_yum'] = true
node.default['postgresql']['version'] = '9.3'
node.default['postgresql']['dir'] = '/var/lib/pgsql/9.3/data'
node.default['postgresql']['config']['data_directory'] = '/var/lib/pgsql/9.3/data'
node.default['postgresql']['config']['shared_preload_libraries'] = 'pg_stat_statements'
node.default['postgresql']['config']['autovacuum'] = 'on'
node.default['postgresql']['config']['checkpoint_timeout'] = '15min'
node.default['postgresql']['config']['track_activities'] = 'on'
node.default['postgresql']['config']['track_counts'] = 'on'
node.default['postgresql']['config']['vacuum_cost_delay'] = 50
node.default['postgresql']['config_pgtune']['max_connections'] = 160
node.default['postgresql']['pg_hba'] = [
  { 'addr' => '',
    'db' => 'all',
    'method' => 'trust',
    'type' => 'local',
    'user' => 'all',
  },
  { 'addr' => '127.0.0.1/32',
    'db' => 'all',
    'method' => 'trust',
    'type' => 'host',
    'user' => 'all',
  },
  { 'addr' => '::1/128',
    'db' => 'all',
    'method' => 'trust',
    'type' => 'host',
    'user' => 'all',
  }]
node.default['postgresql']['client']['packages'] = [
  'postgresql93',
  'postgresql93-contrib',
  'postgresql93-devel',
]
node.default['postgresql']['server']['packages'] = [
  'postgresql93-server',
]
node.default['postgresql']['server']['service_name'] = 'postgresql-9.3'
node.default['postgresql']['contrib']['packages'] = [
  'postgresql93-contrib',
]
node.default['postgresql']['contrib']['extensions'] = %w(
  pageinspect
  pg_buffercache
  pg_freespacemap
  pgrowlocks
  pg_stat_statements
  pgstattuple)

%w(client server contrib config_initdb config_pgtune).each do |r|
  include_recipe "postgresql::#{r}"
end

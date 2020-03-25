# frozen_string_literal: true
#
# Cookbook Name:: opennms-cookbook
# Recipe:: packages
#
# Copyright 2015-2018, ConvergeOne
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
node.default['postgresql']['version'] = '11'
node.default['postgresql']['version'] = '9.6' if Opennms::Helpers.major(node['opennms']['version']).to_i < 25
node.default['postgresql']['version'] = '9.5' if Opennms::Helpers.major(node['opennms']['version']).to_i < 18

if upgrade_required?

  log 'stopping opennms before postgresql upgrade' do
    notifies :stop, 'service[opennms]', :immediately
  end

  old_version = version_from_data_dir(old_data_dir)
  new_version = node.default['postgresql']['version']

  service "postgresql-#{old_version}" do
    action [:stop]
  end

  include_recipe 'opennms::postgres_install'

  old_bins = binary_path_for(old_version)
  new_bins = binary_path_for(new_version)

  odd = old_data_dir
  ndd = new_data_dir

  s_file = sentinel_file

  log "stopping postgres-#{new_version}" do
    notifies :stop, "service[postgresql-#{new_version}]", :immediately
  end

  execute 'upgrade postgresql' do
    command <<-EOM.gsub(/\s+/, ' ').strip!
       #{new_bins}/pg_upgrade
        --old-datadir=#{odd}
        --new-datadir=#{ndd}
        --old-bindir=#{old_bins}
        --new-bindir=#{new_bins}
        --old-options=" -c config_file=#{::File.join(odd, 'postgresql.conf')}"
        --new-options=" -c config_file=#{::File.join(ndd, 'postgresql.conf')}"
      && date > #{s_file}
    EOM
    user node['opennms']['collectd']['example1']['service']['postgresql']['user']
    cwd ndd
    creates s_file
    timeout node['opennms']['posgresql']['pg_upgrade_timeout']
    notifies :start, "service[postgresql-#{new_version}]", :immediately
  end

  log 'starting opennms after postgresql upgrade' do
    notifies :start, 'service[opennms]', :immediately
  end
else
  Chef::Log.info 'Not upgrading PostgreSQL'
  include_recipe 'opennms::postgres_install'
end

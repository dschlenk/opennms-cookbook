# frozen_string_literal: true
#
# Cookbook:: opennms
# Recipe:: adminpw
#
# Copyright:: 2016-2024, ConvergeOne Holding Corp
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

ruby_block 'set admin password' do
  block do
    adminpw = admin_secret_from_vault('password')
    if adminpw != 'admin' && default_admin_password?
      resources(service: 'opennms').run_action(:start)
      set_admin_password(adminpw)
    end
  end
end
# maybe change the admin password
ruby_block 'change admin password' do
  block do
    adminpw = admin_secret_from_vault('password')
    new_adminpw = admin_secret_from_vault('new_password')
    if new_adminpw
      change_admin_password(adminpw, new_adminpw)
      declare_resource(:chef_vault_secret, node['opennms']['users']['admin']['vault_item']) do
        data_bag node['opennms']['admin']['vault']
        raw_data(
          'password' => new_adminpw
        )
      end
    else
      Chef::Log.warn('No new admin password')
    end
  end
end

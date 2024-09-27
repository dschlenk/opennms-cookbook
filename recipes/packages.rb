#
# Cookbook:: opennms
# Recipe:: packages
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
#
if !node['opennms']['upgrade'] && upgrade.upgrade?
  Chef::Log.warn('The current version does not match the configured version, but upgrades are disabled, so we\'re bailing out of the `packages` recipe early.')
  return
end

include_recipe 'opennms::repositories' if node['opennms']['manage_repos']

onms_packages = %w(opennms-core opennms-webapp-jetty)
onms_versions = [node['opennms']['version'], node['opennms']['version']]
node['opennms']['plugin']['addl'].each do |plugin|
  Chef::Log.debug "adding plugin #{plugin}"
  onms_packages.push plugin
  onms_versions.push node['opennms']['version']
end

ruby_block 'stop opennms before upgrade' do
  block do
    resources(:service => 'opennms').run_action(:stop)
  end
  only_if { node['opennms']['upgrade'] && upgrade.upgrade? }
end

#onms_packages.each do |pkg|
#  pv = "#{pkg}-#{node['opennms']['version']}"
#  # remove any version locks that don't match current version
#  execute "remove old versionlocks for #{pkg}" do
#    command "yum versionlock delete 0:#{pkg}*"
#    ignore_failure true
#    not_if "yum versionlock list | grep -q #{pkg}-0:#{node['opennms']['version']}"
#    node['opennms']['repos']['branches'].each do |branch|
#      node['opennms']['repos']['platforms'].each do |_platform|
#        skip = false
#        Chef::Log.debug "branch is '#{branch}' and stable is #{node['opennms']['stable']}"
#        if (branch == 'stable' && !node['opennms']['stable']) ||
#           (branch == 'snapshot' && node['opennms']['stable'])
#          skip = true
#        end
#        next if skip
#      end
#    end
#  end
#  execute "add yum versionlock for #{pkg}" do
#    command "yum versionlock add #{pv}"
#    not_if "yum versionlock list #{pv} | grep -q #{pkg}-0:#{node['opennms']['version']}"
#  end
#end

dnf_package 'python3-dnf-plugin-versionlock'
dnf_package onms_packages do
  action :unlock
  only_if { node['opennms']['upgrade'] && upgrade.upgrade? }
end
dnf_package onms_packages do
  version onms_versions
  timeout node['yum_timeout']
  flush_cache :before
  action [:install, :lock]
end

ruby_block 'do post-upgrade cleanup' do
  block do
    upgrade.upgrade
  end
  only_if { node['opennms']['upgrade'] && upgrade.upgraded? }
end

ruby_block 'start opennms after upgrade' do
  block do
    resources(:service => 'opennms').run_action(:start)
  end
  only_if { node['opennms']['upgrade'] }
end

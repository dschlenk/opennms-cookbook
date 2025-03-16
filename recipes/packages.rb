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

include_recipe 'opennms::repositories'

onms_packages = %w(opennms-core opennms-webapp-jetty)
onms_versions = [node['opennms']['version'], node['opennms']['version']]
node['opennms']['plugin']['addl'].each do |plugin|
  onms_packages.push plugin
  onms_versions.push node['opennms']['version']
end

ruby_block 'stop opennms before upgrade' do
  block do
    resources(service: 'opennms').run_action(:stop)
  end
  only_if { node['opennms']['upgrade'] && upgrade.upgrade? }
end

# the former is needed for dnf_package action `:lock` and the latter for `$OPENNMS_HOME/bin/send-event.pl
dnf_package %w(python3-dnf-plugin-versionlock perl-Sys-Hostname)

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

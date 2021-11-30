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
#
include_recipe 'opennms::repositories' if node['opennms']['manage_repos']
onms_packages = ['opennms-core', 'opennms-webapp-jetty', 'opennms-docs']

onms_versions = [node['opennms']['version'], node['opennms']['version'],
                 node['opennms']['version']]

# version 28.0.1-1 remove opennms-docs
if node['opennms']['version'].to_i >= 28
  onms_packages = ['opennms-core', 'opennms-webapp-jetty']
  onms_versions = [node['opennms']['version'], node['opennms']['version']]
end

if node['opennms']['plugin']['xml'] && Opennms::Helpers.major(node['opennms']['version']).to_i <= 18
  onms_packages.push 'opennms-plugin-protocol-xml'
  onms_versions.push node['opennms']['version']
end

if node['opennms']['plugin']['nsclient']
  onms_packages.push 'opennms-plugin-protocol-nsclient'
  onms_versions.push node['opennms']['version']
end

node['opennms']['plugin']['addl'].each do |plugin|
  Chef::Log.warn "adding plugin #{plugin}"
  onms_packages.push plugin
  onms_versions.push node['opennms']['version']
end

ruby_block 'stop opennms before upgrade' do
  block do
    Opennms::Upgrade.stop_opennms(node)
  end
  only_if { node['opennms']['upgrade'] && Opennms::Upgrade.upgrade?(node) }
end

yum_package 'yum-versionlock'

onms_packages.each do |pkg|
  pv = "#{pkg}-#{node['opennms']['version']}"
  # remove any version locks that don't match current version
  execute "remove old versionlocks for #{pkg}" do
    command "yum versionlock delete 0:#{pkg}*"
    ignore_failure true
    not_if "yum versionlock list #{pv} | grep -q #{pv}"
    node['opennms']['repos']['branches'].each do |branch|
      node['opennms']['repos']['platforms'].each do |platform|
        skip = false
        Chef::Log.debug "branch is '#{branch}' and stable is #{node['opennms']['stable']}"
        if (branch == 'stable' && !node['opennms']['stable']) ||
           (branch == 'snapshot' && node['opennms']['stable'])
          skip = true
        end
        next if skip
        notifies :makecache, "yum_repository[opennms-#{branch}-#{platform}]", :immediately if node['opennms']['manage_repos']
      end
    end
  end
  execute "add yum versionlock for #{pkg}" do
    command "yum versionlock add #{pv}"
    not_if "yum versionlock list #{pv} | grep -q #{pv}"
  end
end

yum_package onms_packages do
  version onms_versions
  allow_downgrade node['opennms']['allow_downgrade']
  timeout node['yum_timeout']
  action :install
end

%w(iplike perl-libwww-perl perl-XML-Twig).each do |p|
  package p do
    action :install
  end
end

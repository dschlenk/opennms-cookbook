# frozen_string_literal: true
#
# Cookbook Name:: opennms
# Recipe:: templates
#
# Copyright 2015, Spanlink Communications, Inc
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
onms_home = node['opennms']['conf']['home']
onms_home ||= '/opt/opennms'

# don't make wrappers that change templates support multiple versions
case Opennms::Helpers.major(node['opennms']['version'])
when '16'
  template_dir = 'horizon-16/'
  node.default['opennms']['properties']['reporting']['jasper_version'] = '5.6.1'
when '17'
  template_dir = 'horizon-17/'
when '18'
  template_dir = 'horizon-18/'
when '19'
  template_dir = 'horizon-19/'
when '20'
  template_dir = 'horizon-20/'
when '21'
  template_dir = 'horizon-21/'
when '22'
  template_dir = 'horizon-22/'
when '23'
  template_dir = 'horizon-23/'
when '24'
  template_dir = 'horizon-24/'
when '25'
  template_dir = 'horizon-25/'
end

if Opennms::Helpers.major(node['opennms']['version']).to_i >= 22
  node.default['opennms']['datacollection']['default']['ref_cpq_im'] = true
  node.default['opennms']['datacollection']['default']['ref_mib2_if'] = true
  node.default['opennms']['datacollection']['default']['ref_mib2_pe'] = true
end

node.default['opennms']['conf']['heap_size'] = 2048 if Opennms::Helpers.major(node['opennms']['version']).to_i >= 25

Chef::Log.debug "at compile time, version is #{node['opennms']['version']} and jasper_version is #{node['opennms']['properties']['reporting']['jasper_version']}."

case node['platform_family']
when 'rhel'
  if node['platform_version'].to_i > 6
    template '/usr/lib/systemd/system/opennms.service' do
      source "#{template_dir}opennms.service.erb"
      mode 00664
      owner 'root'
      group 'root'
      variables(
        start_opts: node['opennms']['start_opts'],
        timeout_start_sec: node['opennms']['timeout_start_sec']
      )
      notifies :run, 'execute[reload systemd]', :immediately
    end
  end
end

template "#{onms_home}/etc/opennms.conf" do
  cookbook node['opennms']['conf']['cookbook']
  source "#{template_dir}opennms.conf.erb"
  mode 00664
  owner 'root'
  group 'root'
  notifies :restart, 'service[opennms]'
  variables(
    conf: node['opennms']['conf']
  )
end

template "#{onms_home}/etc/opennms.properties" do
  cookbook node['opennms']['properties']['cookbook']
  source "#{template_dir}opennms.properties.erb"
  mode 0664
  owner 'root'
  group 'root'
  notifies :restart, 'service[opennms]'
  variables(
    conf: node['opennms']['conf'],
    properties: node['opennms']['properties']
  )
end

template "#{onms_home}/etc/log4j2.xml" do
  cookbook node['opennms']['log4j2']['cookbook']
  source "#{template_dir}log4j2.xml.erb"
  mode 00664
  owner 'root'
  group 'root'
  variables(
    log: node['opennms']['log4j2']
  )
end

template "#{onms_home}/jetty-webapps/opennms/WEB-INF/web.xml" do
  cookbook node['opennms']['web']['cookbook']
  source "#{template_dir}web.xml.erb"
  mode 00644
  owner 'root'
  group 'root'
  notifies :restart, 'service[opennms]'
  variables(
    origins: node['opennms']['cors']['origins'],
    credentials: node['opennms']['cors']['credentials']
  )
  not_if { Opennms::Helpers.major(node['opennms']['version']).to_i < 17 }
end

template "#{onms_home}/bin/opennms" do
  cookbook node['opennms']['bin']['cookbook']
  source "#{template_dir}opennms.erb"
  mode 00755
  owner 'root'
  group 'root'
  variables(
    return_code: node['opennms']['bin']['return_code']
  )
  not_if { Opennms::Helpers.major(node['opennms']['version']).to_i < 25 }
end

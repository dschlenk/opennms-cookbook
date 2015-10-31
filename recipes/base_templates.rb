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
onms_home = node[:opennms][:conf][:home]
onms_home ||= '/opt/opennms'

template "#{onms_home}/etc/opennms.conf" do
  cookbook node[:opennms][:conf][:cookbook]
  source "opennms.conf.erb"
  mode 00664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :conf => node[:opennms][:conf]
  )
end

template "#{onms_home}/etc/opennms.properties" do
  cookbook node[:opennms][:properties][:cookbook]
  source "opennms.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :conf => node[:opennms][:conf],
    :properties => node[:opennms][:properties]
  )
end

template "#{onms_home}/etc/log4j2.xml" do
  cookbook node[:opennms][:log4j2][:cookbook]
  source "log4j2.xml.erb"
  mode 00664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :log => node[:opennms][:log4j2]
  )
end

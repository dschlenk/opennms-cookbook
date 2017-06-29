# frozen_string_literal: true
#
# Cookbook Name:: opennms-cookbook
# Recipe:: rrdtool
#
# Copyright (c) 2016 ConvergeOne
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

%w(rrdtool jrrd2).each do |p|
  package p
end

node.default['opennms']['properties']['dc']['store_by_group'] = true
node.default['opennms']['rrd']['strategy_class'] = 'org.opennms.netmgt.rrd.rrdtool.MultithreadedJniRrdStrategy'
node.default['opennms']['rrd']['interface_jar'] = '/usr/share/java/jrrd2.jar'
node.default['opennms']['rrd']['jrrd'] = '/usr/lib64/libjrrd2.so'

template "#{node['opennms']['conf']['home']}/etc/rrd-configuration.properties" do
  source "horizon-#{Opennms::Helpers.major(node['opennms']['version'])}/rrd-configuration.properties.erb"
  cookbook 'opennms'
  mode 0664
  owner 'root'
  group 'root'
  notifies :restart, 'service[opennms]'
  variables(
    strategy_class: node['opennms']['rrd']['strategy_class'],
    interface_jar: node['opennms']['rrd']['interface_jar'],
    jrrd: node['opennms']['rrd']['jrrd'],
    file_extension: node['opennms']['rrd']['file_extension'],
    queue: node['opennms']['rrd']['queue'],
    jrobin: node['opennms']['rrd']['jrobin'],
    usetcp: node['opennms']['rrd']['usetcp'],
    tcp: node['opennms']['rrd']['tcp']
  )
  # this template already included full template recipe
  not_if node['opennms']['templates']
end

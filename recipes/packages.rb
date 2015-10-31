#
# Cookbook Name:: opennms-cookbook
# Recipe:: packages
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
#

cookbook_file '/etc/yum.repos.d/OPENNMS-GPG-KEY' do
  source 'OPENNMS-GPG-KEY'
  mode 00644
  owner 'root'
  group 'root'
end

bash 'import OpenNMS GPG key' do
  code 'rpm --import /etc/yum.repos.d/OPENNMS-GPG-KEY'
  not_if 'rpm -qai "*gpg*" | grep -q OpenNMS'
end

if node['opennms']['stable']
  yum_repository 'opennms-stable-common' do
    description 'RPMs Common to All OpenNMS Architectures RPMs (stable)'
    baseurl node['yum']['opennms-stable-common']['baseurl']
    mirrorlist node['yum']['opennms-stable-common']['url']
    gpgkey 'file:///etc/yum.repos.d/OPENNMS-GPG-KEY'
    failovermethod node['yum']['opennms-stable-common']['failovermethod']
    includepkgs node['yum']['opennms-stable-common']['includepkgs']
    exclude node['yum']['opennms-stable-common']['exclude']
    action :create
  end
  yum_repository 'opennms-stable-rhel6' do
    description 'RedHat Enterprise Linux 6.x and CentOS 6.x RPMs (stable)'
    baseurl node['yum']['opennms-stable-rhel6']['baseurl']
    mirrorlist node['yum']['opennms-stable-rhel6']['url']
    gpgkey 'file:///etc/yum.repos.d/OPENNMS-GPG-KEY'
    includepkgs node['yum']['opennms-stable-rhel6']['includepkgs']
    exclude node['yum']['opennms-stable-rhel6']['exclude']
    action :create
  end
else
  yum_repository 'opennms-snapshot-common' do
      description 'RPMs Common to All OpenNMS Architectures RPMs (stable)'
      baseurl node['yum']['opennms-snapshot-common']['baseurl']
      mirrorlist node['yum']['opennms-snapshot-common']['url']
      gpgkey 'file:///etc/yum.repos.d/OPENNMS-GPG-KEY'
      failovermethod node['yum']['opennms-snapshot-common']['failovermethod']
      includepkgs node['yum']['opennms-snapshot-common']['includepkgs']
      exclude node['yum']['opennms-snapshot-common']['exclude']
      gpgcheck false
      action :create
  end
  yum_repository 'opennms-snapshot-rhel6' do
    description 'RedHat Enterprise Linux 6.x and CentOS 6.x RPMs (stable)'
    baseurl node['yum']['opennms-snapshot-rhel6']['baseurl']
    mirrorlist node['yum']['opennms-snapshot-rhel6']['url']
    gpgkey 'file:///etc/yum.repos.d/OPENNMS-GPG-KEY'
    includepkgs node['yum']['opennms-snapshot-rhel6']['includepkgs']
    exclude node['yum']['opennms-snapshot-rhel6']['exclude']
      gpgcheck false
    action :create
  end
end

onms_packages = ['opennms-core', 'opennms-webapp-jetty', 'opennms-docs']
onms_versions =  [node['opennms']['version'], node['opennms']['version'],
  node['opennms']['version']]

if node['opennms']['plugin']['xml']
  onms_packages.push 'opennms-plugin-protocol-xml'
  onms_versions.push node['opennms']['version']
end

if node['opennms']['plugin']['nsclient']
  onms_packages.push 'opennms-plugin-protocol-nsclient'
  onms_versions.push node['opennms']['version']
end

package onms_packages do
  version onms_versions
  allow_downgrade node['opennms']['allow_downgrade']
  action :install
end

package "iplike" do
  action :install
end

package "perl-libwww-perl" do
  action :install
end
package "perl-XML-Twig" do
  action :install
end

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
    baseurl node['yum']['opennms-stable-common']['baseurl'] unless node['yum']['opennms-stable-common']['baseurl'].nil?
    mirrorlist node['yum']['opennms-stable-common']['url'] unless node['yum']['opennms-stable-common']['url'].nil?
    gpgkey 'file:///etc/yum.repos.d/OPENNMS-GPG-KEY'
    failovermethod node['yum']['opennms-stable-common']['failovermethod'] unless node['yum']['opennms-stable-common']['failovermethod'].nil?
    includepkgs node['yum']['opennms-stable-common']['includepkgs'] unless node['yum']['opennms-stable-common']['includepkgs'].nil?
    exclude node['yum']['opennms-stable-common']['exclude'] unless node['yum']['opennms-stable-common']['exclude'].nil?
    action :create
  end
  yum_repository 'opennms-stable-rhel6' do
    description 'RedHat Enterprise Linux 6.x and CentOS 6.x RPMs (stable)'
    baseurl node['yum']['opennms-stable-rhel6']['baseurl'] unless node['yum']['opennms-stable-rhel6']['baseurl'].nil?
    mirrorlist node['yum']['opennms-stable-rhel6']['url'] unless node['yum']['opennms-stable-rhel6']['url'].nil?
    gpgkey 'file:///etc/yum.repos.d/OPENNMS-GPG-KEY'
    includepkgs node['yum']['opennms-stable-rhel6']['includepkgs'] unless node['yum']['opennms-stable-rhel6']['includepkgs'].nil?
    exclude node['yum']['opennms-stable-rhel6']['exclude'] unless node['yum']['opennms-stable-rhel6']['exclude'].nil?
    action :create
  end
  yum_repository 'opennms-obsolete-common' do
    description 'RPMs Common to All OpenNMS Architectures RPMs (stable)'
    baseurl node['yum']['opennms-obsolete-common']['baseurl'] unless node['yum']['opennms-obsolete-common']['baseurl'].nil?
    mirrorlist node['yum']['opennms-obsolete-common']['url'] unless node['yum']['opennms-obsolete-common']['url'].nil?
    gpgkey 'file:///etc/yum.repos.d/OPENNMS-GPG-KEY'
    failovermethod node['yum']['opennms-obsolete-common']['failovermethod'] unless node['yum']['opennms-obsolete-common']['failovermethod'].nil?
    includepkgs node['yum']['opennms-obsolete-common']['includepkgs'] unless node['yum']['opennms-obsolete-common']['includepkgs'].nil?
    exclude node['yum']['opennms-obsolete-common']['exclude'] unless node['yum']['opennms-obsolete-common']['exclude'].nil?
    action :create
  end
  yum_repository 'opennms-obsolete-rhel6' do
    description 'RedHat Enterprise Linux 6.x and CentOS 6.x RPMs (stable)'
    baseurl node['yum']['opennms-obsolete-rhel6']['baseurl'] unless node['yum']['opennms-obsolete-rhel6']['baseurl'].nil?
    mirrorlist node['yum']['opennms-obsolete-rhel6']['url'] unless node['yum']['opennms-obsolete-rhel6']['url'].nil?
    gpgkey 'file:///etc/yum.repos.d/OPENNMS-GPG-KEY'
    includepkgs node['yum']['opennms-obsolete-rhel6']['includepkgs'] unless node['yum']['opennms-obsolete-rhel6']['includepkgs'].nil?
    exclude node['yum']['opennms-obsolete-rhel6']['exclude'] unless node['yum']['opennms-obsolete-rhel6']['exclude'].nil?
    action :create
  end
else
  yum_repository 'opennms-snapshot-common' do
      description 'RPMs Common to All OpenNMS Architectures RPMs (stable)'
      baseurl node['yum']['opennms-snapshot-common']['baseurl'] unless node['yum']['opennms-snapshot-common']['baseurl'].nil?
      mirrorlist node['yum']['opennms-snapshot-common']['url'] unless node['yum']['opennms-snapshot-common']['url'].nil?
      gpgkey 'file:///etc/yum.repos.d/OPENNMS-GPG-KEY'
      failovermethod node['yum']['opennms-snapshot-common']['failovermethod'] unless node['yum']['opennms-snapshot-common']['failovermethod'].nil?
      includepkgs node['yum']['opennms-snapshot-common']['includepkgs'] unless node['yum']['opennms-snapshot-common']['includepkgs'].nil?
      exclude node['yum']['opennms-snapshot-common']['exclude'] unless node['yum']['opennms-snapshot-common']['exclude'].nil?
      gpgcheck false
      action :create
  end
  yum_repository 'opennms-snapshot-rhel6' do
    description 'RedHat Enterprise Linux 6.x and CentOS 6.x RPMs (stable)'
    baseurl node['yum']['opennms-snapshot-rhel6']['baseurl'] unless node['yum']['opennms-snapshot-rhel6']['baseurl'].nil?
    mirrorlist node['yum']['opennms-snapshot-rhel6']['url'] unless node['yum']['opennms-snapshot-rhel6']['url'].nil?
    gpgkey 'file:///etc/yum.repos.d/OPENNMS-GPG-KEY'
    includepkgs node['yum']['opennms-snapshot-rhel6']['includepkgs'] unless node['yum']['opennms-snapshot-rhel6']['includepkgs'].nil?
    exclude node['yum']['opennms-snapshot-rhel6']['exclude'] unless node['yum']['opennms-snapshot-rhel6']['exclude'].nil?
      gpgcheck false
    action :create
  end
end

onms_packages = ['opennms-core', 'opennms-webapp-jetty', 'opennms-docs']
onms_versions =  [node['opennms']['version'], node['opennms']['version'],
  node['opennms']['version']]

log "xml is a thing? #{node['opennms']['plugin']['xml']}" do
  level :info
end

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

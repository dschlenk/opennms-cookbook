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

def yum_attr(branch, platform, attr)
  node['yum']["opennms-#{branch}-#{platform}"][attr]
end

branches = ['stable', 'obsolete', 'snapshot']
platforms = ['common', 'rhel6']
branches.each do |branch|
  platforms.each do |platform|
    skip = false
    Chef::Log.debug "branch is '#{branch}' and stable is #{node['opennms']['stable']}"
    if ((branch == 'stable' && !node['opennms']['stable']) ||
      (branch == 'snapshot' && node['opennms']['stable']))
      skip = true 
    end
    unless skip
      bu = yum_attr(branch, platform, 'baseurl')
      ml = yum_attr(branch, platform, 'url')
      fom = yum_attr(branch, platform, 'failovermethod')
      inc_pkgs = yum_attr(branch, platform, 'includepkgs')
      ex = yum_attr(branch, platform, 'exclude')
      yum_repository "opennms-#{branch}-#{platform}" do
        description "#{platform} OpenNMS RPMs (#{branch})"
        baseurl bu unless bu.nil? || '' == bu
        mirrorlist ml unless ml.nil? || '' == ml
        gpgkey 'file:///etc/yum.repos.d/OPENNMS-GPG-KEY'
        failovermethod fom unless fom.nil? | '' == fom
        includepkgs inc_pkgs unless inc_pkgs.nil? || '' == inc_pkgs
        exclude ex unless ex.nil? || '' == ex
        action :create
      end
    end
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

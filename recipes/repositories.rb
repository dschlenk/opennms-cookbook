#
# Cookbook:: opennms
# Recipe:: repositories
#
# Copyright:: 2018-2024, ConvergeOne Holding Corp
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

def yum_attr(branch, platform, attr)
  node['yum']["opennms-#{branch}-#{platform}"][attr]
end

branches = node['opennms']['repos']['branches']
platforms = node['opennms']['repos']['platforms']
branches.each do |branch|
  platforms.each do |platform|
    skip = false
    if (branch == 'stable' && !node['opennms']['stable']) ||
       ((branch == 'snapshot' || branch == 'obsolete' || branch == 'oldstable') && node['opennms']['stable'])
      skip = true
    end
    # next if skip
    bu = yum_attr(branch, platform, 'baseurl')
    ml = yum_attr(branch, platform, 'url')
    fom = yum_attr(branch, platform, 'failovermethod')
    inc_pkgs = yum_attr(branch, platform, 'includepkgs')
    repo_enabled = yum_attr(branch, platform, 'enabled')
    ex = yum_attr(branch, platform, 'exclude')
    yum_repository "opennms-#{branch}-#{platform}" do
      description "#{platform} OpenNMS RPMs (#{branch})"
      baseurl bu unless bu.nil? || bu == ''
      mirrorlist ml unless ml.nil? || ml == ''
      gpgkey node['opennms']['yum_gpg_keys']
      failovermethod fom unless fom.nil? || fom == ''
      enabled false if repo_enabled == false || skip
      make_cache false if repo_enabled == false || skip
      includepkgs inc_pkgs unless inc_pkgs.nil? || inc_pkgs == ''
      exclude ex unless ex.nil? || ex == ''
      only_if { node['opennms']['manage_repos'] }
      action :create
    end
  end
end

node['opennms']['repos']['vault'].each do |k|
  yum_repository "opennms-vault-#{k}" do
    description "Vault for OpenNMS #{k} RPMs"
    baseurl "https://vault.opennms.com/horizon/#{k}/rpm"
    gpgkey node['opennms']['yum_gpg_keys']
    enabled true
  end
end

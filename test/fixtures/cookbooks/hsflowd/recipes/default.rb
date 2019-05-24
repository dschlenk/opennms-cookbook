#
# Cookbook:: hsflowd
# Recipe:: default
#
# Copyright:: 2018, ConvergeOne, All Rights Reserved.
remote_file "#{Chef::Config['file_cache_path']}/hsflowd.rpm" do
  source 'https://github.com/sflow/host-sflow/releases/download/v2.0.15/hsflowd-centos6-2.0.15-1.x86_64.rpm'
end
yum_package 'dmidecode'
yum_package 'hsflowd' do
  source "#{Chef::Config['file_cache_path']}/hsflowd.rpm"
end

cookbook_file '/etc/hsflowd.conf' do
  source 'hsflowd.conf'
  mode 00644
  owner 'root'
  group 'root'
end

service 'hsflowd' do
  action [:enable, :start]
end

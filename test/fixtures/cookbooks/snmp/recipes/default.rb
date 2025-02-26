#
# Cookbook:: snmp
# Recipe:: default
#
# Copyright:: 2018, ConvergeOne, All Rights Reserved.
package 'net-snmp'
service 'snmpd' do
  action [:enable, :start]
end
cookbook_file '/etc/snmp/snmpd.conf' do
  owner 'root'
  source 'snmpd.conf'
  group 'root'
  mode '600'
  notifies :restart, 'service[snmpd]', :immediately
end

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

template "#{onms_home}/etc/availability-reports.xml" do
  cookbook node[:opennms][:db_reports][:avail][:cookbook]
  source "availability-reports.xml.erb"
  mode 0664
  owner "root"
  group "root"
  variables(
    :cal_logo              => node['opennms']['db_reports']['avail']['cal']['logo'],
    :cal_interval          => node['opennms']['db_reports']['avail']['cal']['endDate']['interval'],
    :cal_count             => node['opennms']['db_reports']['avail']['cal']['endDate']['count'],
    :cal_hours             => node['opennms']['db_reports']['avail']['cal']['endDate']['hours'],
    :cal_minutes           => node['opennms']['db_reports']['avail']['cal']['endDate']['minutes'],
    :classic_logo          => node['opennms']['db_reports']['avail']['classic']['logo'],
    :classic_interval      => node['opennms']['db_reports']['avail']['classic']['endDate']['interval'],
    :classic_count         => node['opennms']['db_reports']['avail']['classic']['endDate']['count'],
    :classic_hours         => node['opennms']['db_reports']['avail']['classic']['endDate']['hours'],
    :classic_minutes       => node['opennms']['db_reports']['avail']['classic']['endDate']['minutes'],
    :onms_home             => onms_home
  )
end

template "#{onms_home}/etc/service-configuration.xml" do
  cookbook node[:opennms][:services][:cookbook]
  source "service-configuration.xml.erb"
  mode 00664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :dhcpd       => node['opennms']['services']['dhcpd'],
    :snmp_poller => node['opennms']['services']['snmp_poller'],
    :correlator  => node['opennms']['services']['correlator'],
    :tl1d        => node['opennms']['services']['tl1d'],
    :syslogd     => node['opennms']['services']['syslogd'],
    :asterisk_gw => node['opennms']['services']['asterisk_gw'],
    :apm         => node['opennms']['services']['apm']
  )
end

template "#{onms_home}/etc/categories.xml" do
  cookbook node[:opennms][:categories][:cookbook]
  source "categories.xml.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :common_rule => node['opennms']['categories']['common_rule'],
    :overall     => node['opennms']['categories']['overall'],
    :interfaces  => node['opennms']['categories']['interfaces'],
    :email       => node['opennms']['categories']['email'],
    :web         => node['opennms']['categories']['web'],
    :jmx         => node['opennms']['categories']['jmx'],
    :dns         => node['opennms']['categories']['dns'],
    :db          => node['opennms']['categories']['db'],
    :other       => node['opennms']['categories']['other'],
    :inet        => node['opennms']['categories']['inet']
  )
end

template "#{onms_home}/etc/chart-configuration.xml" do
  cookbook node[:opennms][:chart][:cookbook]
  source "chart-configuration.xml.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :severity_enable  => node['opennms']['chart']['severity_enable'],
    :outages_enable   => node['opennms']['chart']['outages_enable'],
    :inventory_enable => node['opennms']['chart']['inventory_enable']
  )
end

template "#{onms_home}/etc/collectd-configuration.xml" do
  cookbook node[:opennms][:collectd][:cookbook]
  source "collectd-configuration.xml.erb"
  mode 0664
  owner "root"
  group "root"
  variables(
    :threads  => node['opennms']['collectd']['threads'],
    :vmware3  => node['opennms']['collectd']['vmware3'],
    :vmware4  => node['opennms']['collectd']['vmware4'],
    :vmware5  => node['opennms']['collectd']['vmware5'],
    :example1 => node['opennms']['collectd']['example1']
  )
end

template "#{onms_home}/etc/datacollection-config.xml" do
  cookbook node[:opennms][:datacollection][:cookbook]
  source "datacollection-config.xml.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :rrd_base_dir => node['opennms']['properties']['dc']['rrd_base_dir'],
    :rrd_dc_dir   => node['opennms']['properties']['dc']['rrd_dc_dir'],
    :default      => node['opennms']['datacollection']['default'],
    :mib2         => node['opennms']['datacollection']['default']['mib2'],
    :threecom     => node['opennms']['datacollection']['default']['threecom'],
    :acme         => node['opennms']['datacollection']['default']['acme'],
    :akcp         => node['opennms']['datacollection']['default']['akcp'],
    :alvarion     => node['opennms']['datacollection']['default']['alvarion'],
    :apc          => node['opennms']['datacollection']['default']['apc'],
    :ascend       => node['opennms']['datacollection']['default']['ascend'],
    :asterisk     => node['opennms']['datacollection']['default']['asterisk'],
    :bluecat      => node['opennms']['datacollection']['default']['bluecat'],
    :bluecoat     => node['opennms']['datacollection']['default']['bluecoat'],
    :brocade      => node['opennms']['datacollection']['default']['brocade'],
    :checkpoint   => node['opennms']['datacollection']['default']['checkpoint'],
    :cisco        => node['opennms']['datacollection']['default']['cisco'],
    :ciscoNexus   => node['opennms']['datacollection']['default']['ciscoNexus'],
    :clavister    => node['opennms']['datacollection']['default']['clavister'],
    :colubris     => node['opennms']['datacollection']['default']['colubris'],
    :concord      => node['opennms']['datacollection']['default']['concord'],
    :cyclades     => node['opennms']['datacollection']['default']['cyclades'],
    :dell         => node['opennms']['datacollection']['default']['dell'],
    :ericsson     => node['opennms']['datacollection']['default']['ericsson'],
    :equallogic   => node['opennms']['datacollection']['default']['equallogic'],
    :extreme      => node['opennms']['datacollection']['default']['extreme'],
    :f5           => node['opennms']['datacollection']['default']['f5'],
    :fortinet     => node['opennms']['datacollection']['default']['fortinet'],
    :force10      => node['opennms']['datacollection']['default']['force10'],
    :foundry      => node['opennms']['datacollection']['default']['foundry'],
    :hp           => node['opennms']['datacollection']['default']['hp'],
    :hwg          => node['opennms']['datacollection']['default']['hwg'],
    :ibm          => node['opennms']['datacollection']['default']['ibm'],
    :ipunity      => node['opennms']['datacollection']['default']['ipunity'],
    :juniper      => node['opennms']['datacollection']['default']['juniper'],
    :konica       => node['opennms']['datacollection']['default']['konica'],
    :kyocera      => node['opennms']['datacollection']['default']['kyocera'],
    :lexmark      => node['opennms']['datacollection']['default']['lexmark'],
    :liebert      => node['opennms']['datacollection']['default']['liebert'],
    :makelsan     => node['opennms']['datacollection']['default']['makelsan'],
    :mge          => node['opennms']['datacollection']['default']['mge'],
    :microsoft    => node['opennms']['datacollection']['default']['microsoft'],
    :mikrotik     => node['opennms']['datacollection']['default']['mikrotik'],
    :netapp       => node['opennms']['datacollection']['default']['netapp'],
    :netbotz      => node['opennms']['datacollection']['default']['netbotz'],
    :netenforcer  => node['opennms']['datacollection']['default']['netenforcer'],
    :netscaler    => node['opennms']['datacollection']['default']['netscaler'],
    :netsnmp      => node['opennms']['datacollection']['default']['netsnmp'],
    :nortel       => node['opennms']['datacollection']['default']['nortel'],
    :novell       => node['opennms']['datacollection']['default']['novell'],
    :pfsense      => node['opennms']['datacollection']['default']['pfsense'],
    :powerware    => node['opennms']['datacollection']['default']['powerware'],
    :postgres     => node['opennms']['datacollection']['default']['postgres'],
    :riverbed     => node['opennms']['datacollection']['default']['riverbed'],
    :savin        => node['opennms']['datacollection']['default']['savin'],
    :servertech   => node['opennms']['datacollection']['default']['servertech'],
    :sofaware     => node['opennms']['datacollection']['default']['sofaware'],
    :sun          => node['opennms']['datacollection']['default']['sun'],
    :trango       => node['opennms']['datacollection']['default']['trango'],
    :wmi          => node['opennms']['datacollection']['default']['wmi'],
    :xmp          => node['opennms']['datacollection']['default']['xmp'],
    :zertico      => node['opennms']['datacollection']['default']['zertico'],
    :zeus         => node['opennms']['datacollection']['default']['zeus'],
    :vmware3      => node['opennms']['datacollection']['default']['vmware3'],
    :vmware4      => node['opennms']['datacollection']['default']['vmware4'],
    :vmware5      => node['opennms']['datacollection']['default']['vmware5'],
    :vmwarecim    => node['opennms']['datacollection']['default']['vmwarecim'],
    :ejn          => node['opennms']['datacollection']['ejn']
  )
end

if node['opennms']['plugin']['xml']
  template "#{onms_home}/etc/xml-datacollection-config.xml" do
    cookbook node[:opennms][:xml][:cookbook]
    source "xml-datacollection-config.xml.erb"
    mode 00664
    owner "root"
    group "root"
    notifies :restart, "service[opennms]"
    variables( 
      :rrd_repository      => node[:opennms][:xml][:rrd_repository],
      :threegpp_full_5min  => node[:opennms][:xml][:threegpp_full_5min],
      :threegpp_full_15min => node[:opennms][:xml][:threegpp_full_15min],
      :threegpp_sample     => node[:opennms][:xml][:threegpp_sample]
    )
  end
end

if node['opennms']['plugin']['nsclient']
  template "#{onms_home}/etc/nsclient-datacollection-config.xml" do
    cookbook node[:opennms][:nsclient_datacollection][:cookbook]
    source "nsclient-datacollection-config.xml.erb"
    mode 00664
    owner "root"
    group "root"
    notifies :restart, "service[opennms]"
    variables(
      :rrd_repository => node[:opennms][:nsclient_datacollection][:rrd_repository],
      :enable_default => node[:opennms][:nsclient_datacollection][:enable_default],
      :default        => node[:opennms][:nsclient_datacollection][:default],
      :processor      => node[:opennms][:nsclient_datacollection][:default][:processor],
      :system         => node[:opennms][:nsclient_datacollection][:default][:system],
      :iis            => node[:opennms][:nsclient_datacollection][:default][:iis],
      :exchange       => node[:opennms][:nsclient_datacollection][:default][:exchange],
      :dns            => node[:opennms][:nsclient_datacollection][:default][:dns],
      :sqlserver      => node[:opennms][:nsclient_datacollection][:default][:sqlserver],
      :biztalk        => node[:opennms][:nsclient_datacollection][:default][:biztalk],
      :live           => node[:opennms][:nsclient_datacollection][:default][:live],
      :mailmarshal    => node[:opennms][:nsclient_datacollection][:default][:mailmarshal]
    )
  end
end
  
template "#{onms_home}/etc/discovery-configuration.xml" do
  cookbook node[:opennms][:discovery][:cookbook]
  source "discovery-configuration.xml.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :threads          => node['opennms']['discovery']['threads'],
    :pps              => node['opennms']['discovery']['pps'],
    :init_sleep_ms    => node['opennms']['discovery']['init_sleep_ms'],
    :restart_sleep_ms => node['opennms']['discovery']['restart_sleep_ms'],
    :retries          => node['opennms']['discovery']['retries'],
    :timeout          => node['opennms']['discovery']['timeout'],
    :foreign_source   => node['opennms']['discovery']['foreign_source']
  )
end

template "#{onms_home}/etc/enlinkd-configuration.xml" do
  cookbook node[:opennms][:enlinkd][:cookbook]
  source "enlinkd-configuration.xml.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :threads         => node['opennms']['enlinkd']['threads'],
    :init_sleep_time => node['opennms']['enlinkd']['init_sleep_time'],
    :rescan_interval => node['opennms']['enlinkd']['rescan_interval'],
    :cdp             => node['opennms']['enlinkd']['cdp'],
    :bridge          => node['opennms']['enlinkd']['bridge'],
    :lldp            => node['opennms']['enlinkd']['lldp'],
    :ospf            => node['opennms']['enlinkd']['ospf'],
    :isis            => node['opennms']['enlinkd']['isis']
  )
end

template "#{onms_home}/etc/eventd-configuration.xml" do
  cookbook node[:opennms][:eventd][:cookbook]
  source "eventd-configuration.xml.erb"
  mode 00664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :tcp_address            => node['opennms']['eventd']['tcp_address'],
    :tcp_port               => node['opennms']['eventd']['tcp_port'],
    :udp_address            => node['opennms']['eventd']['udp_address'],
    :udp_port               => node['opennms']['eventd']['udp_port'],
    :receivers              => node['opennms']['eventd']['receivers'],
    :get_next_eventid       => node['opennms']['eventd']['get_next_eventid'],
    :sock_so_timeout_req    => node['opennms']['eventd']['sock_so_timeout_req'],
    :socket_so_timeout_period => node['opennms']['eventd']['socket_so_timeout_period']
  )
end

template "#{onms_home}/etc/javamail-configuration.properties" do
  cookbook node[:opennms][:javamail_props][:cookbook]
  source "javamail-configuration.properties.erb"
  mode 00664
  owner "root"
  group "root"
  variables(
    :from_address          => node[:opennms][:javamail_props][:from_address],
    :mail_host             => node[:opennms][:javamail_props][:mail_host],
    :mailer                => node[:opennms][:javamail_props][:mailer],
    :transport             => node[:opennms][:javamail_props][:transport],
    :debug                 => node[:opennms][:javamail_props][:debug],
    :smtpport              => node[:opennms][:javamail_props][:smtpport],
    :smtpssl               => node[:opennms][:javamail_props][:smtpssl],
    :quitwait              => node[:opennms][:javamail_props][:quitwait],
    :use_JMTA              => node[:opennms][:javamail_props][:use_JMTA],
    :authenticate          => node[:opennms][:javamail_props][:authenticate],
    :authenticate_user     => node[:opennms][:javamail_props][:authenticate_user],
    :authenticate_password => node[:opennms][:javamail_props][:authenticate_password],
    :starttls              => node[:opennms][:javamail_props][:starttls],
    :message_content_type  => node[:opennms][:javamail_props][:message_content_type],
    :charset               => node[:opennms][:javamail_props][:charset]
  )
end

template "#{onms_home}/etc/javamail-configuration.xml" do
  cookbook node[:opennms][:javamail_config][:cookbook]
  source "javamail-configuration.xml.erb"
  mode 00664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :default_read_config_name        => node[:opennms][:javamail_config][:default_read_config_name],
    :default_send_config_name        => node[:opennms][:javamail_config][:default_send_config_name],
    :dr_attempt_interval             => node[:opennms][:javamail_config][:default_read][:attempt_interval],
    :dr_delete_all_mail              => node[:opennms][:javamail_config][:default_read][:delete_all_mail],
    :dr_mail_folder                  => node[:opennms][:javamail_config][:default_read][:mail_folder],
    :dr_debug                        => node[:opennms][:javamail_config][:default_read][:debug],
    :dr_properties                   => node[:opennms][:javamail_config][:default_read][:properties],
    :dr_host                         => node[:opennms][:javamail_config][:default_read][:host],
    :dr_port                         => node[:opennms][:javamail_config][:default_read][:port],
    :dr_ssl_enable                   => node[:opennms][:javamail_config][:default_read][:ssl_enable],
    :dr_start_tls                    => node[:opennms][:javamail_config][:default_read][:start_tls],
    :dr_transport                    => node[:opennms][:javamail_config][:default_read][:transport],
    :dr_user                         => node[:opennms][:javamail_config][:default_read][:user],
    :dr_password                     => node[:opennms][:javamail_config][:default_read][:password],
    :ds_attempt_interval             => node[:opennms][:javamail_config][:default_send][:attempt_interval],
    :ds_use_authentication           => node[:opennms][:javamail_config][:default_send][:use_authentication],
    :ds_use_jmta                     => node[:opennms][:javamail_config][:default_send][:use_jmta],
    :ds_debug                        => node[:opennms][:javamail_config][:default_send][:debug],
    :ds_host                         => node[:opennms][:javamail_config][:default_send][:host],
    :ds_port                         => node[:opennms][:javamail_config][:default_send][:port],
    :ds_char_set                     => node[:opennms][:javamail_config][:default_send][:char_set],
    :ds_mailer                       => node[:opennms][:javamail_config][:default_send][:mailer],
    :ds_content_type                 => node[:opennms][:javamail_config][:default_send][:content_type],
    :ds_encoding                     => node[:opennms][:javamail_config][:default_send][:encoding],
    :ds_quit_wait                    => node[:opennms][:javamail_config][:default_send][:quit_wait],
    :ds_ssl_enable                   => node[:opennms][:javamail_config][:default_send][:ssl_enable],
    :ds_start_tls                    => node[:opennms][:javamail_config][:default_send][:start_tls],
    :ds_transport                    => node[:opennms][:javamail_config][:default_send][:transport],
    :ds_to                           => node[:opennms][:javamail_config][:default_send][:to],
    :ds_from                         => node[:opennms][:javamail_config][:default_send][:from],
    :ds_subject                      => node[:opennms][:javamail_config][:default_send][:subject],
    :ds_body                         => node[:opennms][:javamail_config][:default_send][:body],
    :ds_user                         => node[:opennms][:javamail_config][:default_send][:user],
    :ds_password                     => node[:opennms][:javamail_config][:default_send][:password]
  )
end

template "#{onms_home}/etc/jcifs.properties" do
  cookbook node[:opennms][:jcifs][:cookbook]
  source "jcifs.properties.erb"
  mode 00664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :loglevel      => node[:opennms][:jcifs][:loglevel],
    :wins          => node[:opennms][:jcifs][:wins],
    :lmhosts       => node[:opennms][:jcifs][:lmhosts],
    :resolve_order => node[:opennms][:jcifs][:resolve_order],
    :hostname      => node[:opennms][:jcifs][:hostname],
    :retry_count   => node[:opennms][:jcifs][:retry_count],
    :username      => node[:opennms][:jcifs][:username],
    :password      => node[:opennms][:jcifs][:password],
    :client_laddr  => node[:opennms][:jcifs][:client_laddr]
  )
end

template "#{onms_home}/etc/jdbc-datacollection-config.xml" do
  cookbook node[:opennms][:jdbc_dc][:cookbook]
  source "jdbc-datacollection-config.xml.erb"
  mode 00664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :rrd_repository     => node[:opennms][:jdbc_dc][:rrd_repository],
    :enable_default     => node[:opennms][:jdbc_dc][:enable_default],
    :default            => node[:opennms][:jdbc_dc][:default],
    :enable_mysql_stats => node[:opennms][:jdbc_dc][:enable_mysql_stats],
    :mysql              => node[:opennms][:jdbc_dc][:mysql],
    :enable_pgsql_stats => node[:opennms][:jdbc_dc][:enable_pgsql_stats],
    :pgsql              => node[:opennms][:jdbc_dc][:pgsql]
  )
end

template "#{onms_home}/etc/jmx-datacollection-config.xml" do
  cookbook node[:opennms][:jmx_dc][:cookbook]
  source "jmx-datacollection-config.xml.erb"
  mode 00644
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :rrd_repository => node[:opennms][:jmx_dc][:rrd_repository],
    :enable_jboss   => node[:opennms][:jmx_dc][:enable_jboss],
    :jboss          => node[:opennms][:jmx_dc][:jboss],
    :enable_opennms => node[:opennms][:jmx_dc][:enable_opennms],
    :jsr160         => node[:opennms][:jmx_dc][:jsr160]
  )
end

template "#{onms_home}/etc/linkd-configuration.xml" do
  cookbook node[:opennms][:linkd][:cookbook]
  source "linkd-configuration.xml.erb"
  mode 00664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :threads                      => node[:opennms][:linkd][:threads],
    :initial_sleep_time           => node[:opennms][:linkd][:initial_sleep_time],
    :snmp_poll_interval           => node[:opennms][:linkd][:snmp_poll_interval],
    :discovery_link_interval      => node[:opennms][:linkd][:discovery_link_interval],
    :package                      => node[:opennms][:linkd][:package],
    :filter                       => node[:opennms][:linkd][:filter],
    :range_begin                  => node[:opennms][:linkd][:range_begin],
    :range_end                    => node[:opennms][:linkd][:range_end],
    :netscreen                    => node[:opennms][:linkd][:iproutes][:enable_netscreen],
    :samsung                      => node[:opennms][:linkd][:iproutes][:enable_samsung],
    :iproute_cisco                => node[:opennms][:linkd][:iproutes][:enable_cisco],
    :darwin                       => node[:opennms][:linkd][:iproutes][:enable_darwin],
    :vlan_3com                    => node[:opennms][:linkd][:vlan][:enable_3com],
    :vlan_3com3870                => node[:opennms][:linkd][:vlan][:enable_3com3870],
    :vlan_nortel                  => node[:opennms][:linkd][:vlan][:enable_nortel],
    :vlan_intel                   => node[:opennms][:linkd][:vlan][:enable_intel],
    :vlan_hp                      => node[:opennms][:linkd][:vlan][:enable_hp],
    :vlan_cisco                   => node[:opennms][:linkd][:vlan][:enable_cisco],
    :vlan_extreme                 => node[:opennms][:linkd][:vlan][:enable_extreme]
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

template "#{onms_home}/etc/magic-users.properties" do
  cookbook node[:opennms][:magic_users][:cookbook]
  source "magic-users.properties.erb"
  mode 00664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :rtc_username    => node[:opennms][:properties][:rtc][:username],
    :rtc_password    => node[:opennms][:properties][:rtc][:password],
    :admin_users     => node[:opennms][:magic_users][:admin_users],
    :ro_users        => node[:opennms][:magic_users][:ro_users],
    :dashboard_users => node[:opennms][:magic_users][:dashboard_users],
    :provision_users => node[:opennms][:magic_users][:provision_users],
    :remoting_users  => node[:opennms][:magic_users][:remoting_users],
    :rest_users      => node[:opennms][:magic_users][:rest_users]
  )
end

template "#{onms_home}/etc/map.properties" do
  cookbook node[:opennms][:map][:cookbook]
  source "map.properties.erb"
  mode 00664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :critical           => node[:opennms][:map][:severity][:critical],
    :major              => node[:opennms][:map][:severity][:major],
    :minor              => node[:opennms][:map][:severity][:minor],
    :warning            => node[:opennms][:map][:severity][:warning],
    :normal             => node[:opennms][:map][:severity][:normal],
    :cleared            => node[:opennms][:map][:severity][:cleared],
    :indeterminate      => node[:opennms][:map][:severity][:indeterminate],
    :default            => node[:opennms][:map][:severity][:default],
    :ethernet_text      => node[:opennms][:map][:link][:ethernet][:text],
    :fastethernet_text  => node[:opennms][:map][:link][:fastethernet][:text],
    :fastethernet2_text => node[:opennms][:map][:link][:fastethernet2][:text],
    :gigaethernet_text  => node[:opennms][:map][:link][:gigaethernet][:text],
    :gigaethernet2_text => node[:opennms][:map][:link][:gigaethernet2][:text],
    :serial_text        => node[:opennms][:map][:link][:serial][:text],
    :framerelay_text    => node[:opennms][:map][:link][:framerelay][:text],
    :ieee80211_text     => node[:opennms][:map][:link][:ieee80211][:text],
    :unknown_text       => node[:opennms][:map][:link][:unknown][:text],
    :dwo_text           => node[:opennms][:map][:link][:dwo][:text],
    :summary_text       => node[:opennms][:map][:link][:summary][:text],
    :link_default       => node[:opennms][:map][:link][:default],
    :multilink          => node[:opennms][:map][:multilink],
    :linkstatus         => node[:opennms][:map][:linkstatus],
    :status             => node[:opennms][:map][:status],
    :avail              => node[:opennms][:map][:avail],
    :icon               => node[:opennms][:map][:icon],
    :cmenu              => node[:opennms][:map][:cmenu],
    :severity           => node[:opennms][:map][:severity],
    :enable             => node[:opennms][:map][:enable]
  )
end

template "#{onms_home}/etc/microblog-configuration.xml" do
  cookbook node[:opennms][:microblog][:cookbook]
  source "microblog-configuration.xml.erb"
  mode 00664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :default_profile => node[:opennms][:microblog][:default_profile]
  )
end

template "#{onms_home}/etc/model-importer.properties" do
  cookbook node[:opennms][:importer][:cookbook]
  source "model-importer.properties.erb"
  mode 00664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :import_url => node[:opennms][:importer][:import_url],
    :schedule => node[:opennms][:importer][:schedule],
    :threads => node[:opennms][:importer][:threads],
    :scan_threads => node[:opennms][:importer][:scan_threads],
    :write_threads => node[:opennms][:importer][:write_threads],
    :requisition_dir => node[:opennms][:importer][:requisition_dir],
    :foreign_source_dir => node[:opennms][:importer][:foreign_source_dir]
  )
end

template "#{onms_home}/etc/modemConfig.properties" do
  cookbook node[:opennms][:modem][:cookbook]
  source "modemConfig.properties.erb"
  mode 00664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :modem => node[:opennms][:modem][:model],
    :custom_modem => node[:opennms][:custom_modem]
  )
end

template "#{onms_home}/etc/notifd-configuration.xml" do
  cookbook node[:opennms][:notifd][:cookbook]
  source "notifd-configuration.xml.erb"
  mode 00664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :status    => node[:opennms][:notifd][:status],
    :match_all => node[:opennms][:notifd][:match_all],
    :auto_ack  => node[:opennms][:notifd][:auto_ack]
  )
end

template "#{onms_home}/etc/notificationCommands.xml" do
  cookbook node[:opennms][:notification_commands][:cookbook]
  source "notificationCommands.xml.erb"
  mode 00664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :java_pager_email   => node['opennms']['notification_commands']['java_pager_email'],
    :java_email         => node['opennms']['notification_commands']['java_email'],
    :text_page          => node['opennms']['notification_commands']['text_page'],
    :numeric_page       => node['opennms']['notification_commands']['numeric_page'],
    :xmpp_message       => node['opennms']['notification_commands']['xmpp_message'],
    :xmpp_group_message => node['opennms']['notification_commands']['xmpp_group_message'],
    :irc_cat            => node['opennms']['notification_commands']['irc_cat'],
    :call_work_phone    => node['opennms']['notification_commands']['call_work_phone'],
    :call_mobile_phone  => node['opennms']['notification_commands']['call_mobile_phone'],
    :call_home_phone    => node['opennms']['notification_commands']['call_home_phone'],
    :microblog_update   => node['opennms']['notification_commands']['microblog_update'],
    :microblog_reply    => node['opennms']['notification_commands']['microblog_reply'],
    :microblog_dm       => node['opennms']['notification_commands']['microblog_dm']
  )
end

template "#{onms_home}/etc/notifications.xml" do
  cookbook node[:opennms][:notifications][:cookbook]
  source "notifications.xml.erb"
  mode 00664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :interface_down         => node[:opennms][:notifications][:interface_down],
    :node_down              => node[:opennms][:notifications][:node_down],
    :node_lost_service      => node[:opennms][:notifications][:node_lost_service],
    :node_added             => node[:opennms][:notifications][:node_added],
    :interface_deleted      => node[:opennms][:notifications][:interface_deleted],
    :high_threshold         => node[:opennms][:notifications][:high_threshold],
    :low_threshold          => node[:opennms][:notifications][:low_threshold],
    :low_threshold_rearmed  => node[:opennms][:notifications][:low_threshold_rearmed],
    :high_threshold_rearmed => node[:opennms][:notifications][:high_threshold_rearmed]
  )
end

template "#{onms_home}/etc/poller-configuration.xml" do
  cookbook node[:opennms][:poller][:cookbook]
  source "poller-configuration.xml.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :threads                        => node[:opennms][:poller][:threads],
    :service_unresponsive_enabled   => node[:opennms][:poller][:service_unresponsive_enabled],
    :node_outage                    => node[:opennms][:poller][:node_outage],
    :example1                       => node[:opennms][:poller][:example1],
    :icmp                           => node[:opennms][:poller][:example1][:icmp],
    :dns                            => node[:opennms][:poller][:example1][:dns],
    :smtp                           => node[:opennms][:poller][:example1][:smtp],
    :ftp                            => node[:opennms][:poller][:example1][:ftp],
    :snmp                           => node[:opennms][:poller][:example1][:snmp],
    :http                           => node[:opennms][:poller][:example1][:http],
    :http_8080                      => node[:opennms][:poller][:example1][:http_8080],
    :http_8000                      => node[:opennms][:poller][:example1][:http_8000],
    :https                          => node[:opennms][:poller][:example1][:https],
    :hyperic_agent                  => node[:opennms][:poller][:example1][:hyperic_agent],
    :hyperichq                      => node[:opennms][:poller][:example1][:hyperichq],
    :mysql                          => node[:opennms][:poller][:example1][:mysql],
    :sqlserver                      => node[:opennms][:poller][:example1][:sqlserver],
    :oracle                         => node[:opennms][:poller][:example1][:oracle],
    :postgres                       => node[:opennms][:poller][:example1][:postgres],
    :ssh                            => node[:opennms][:poller][:example1][:ssh],
    :imap                           => node[:opennms][:poller][:example1][:imap],
    :pop3                           => node[:opennms][:poller][:example1][:pop3],
    :nrpe                           => node[:opennms][:poller][:example1][:nrpe],
    :nrpe_nossl                     => node[:opennms][:poller][:example1][:nrpe_nossl],
    :win_task_sched                 => node[:opennms][:poller][:example1][:win_task_sched],
    :opennms_jvm                    => node[:opennms][:poller][:example1][:opennms_jvm],
    :vmware_host                    => node[:opennms][:poller][:example1][:vmware_host],
    :vmware_entity                  => node[:opennms][:poller][:example1][:vmware_entity],
    :strafer                        => node[:opennms][:poller][:strafer],
    :strafeping                     => node[:opennms][:poller][:strafer][:strafeping]
  )
end

template "#{onms_home}/etc/provisiond-configuration.xml" do
  cookbook node[:opennms][:importer][:cookbook]
  source "provisiond-configuration.xml.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :foreign_source_dir => node[:opennms][:importer][:foreign_source_dir],
    :requisition_dir    => node[:opennms][:importer][:requisition_dir],
    :import_threads     => node[:opennms][:importer][:threads],
    :scan_threads       => node[:opennms][:importer][:scan_threads],
    :rescan_threads     => node[:opennms][:importer][:rescan_threads],
    :write_threads      => node[:opennms][:importer][:write_threads]
  )
end

template "#{onms_home}/etc/remedy.properties" do
  cookbook node[:opennms][:remedy][:cookbook]
  source "remedy.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :username                     => node[:opennms][:remedy][:username],
    :password                     => node[:opennms][:remedy][:password],
    :authentication               => node[:opennms][:remedy][:authentication],
    :locale                       => node[:opennms][:remedy][:locale],
    :timezone                     => node[:opennms][:remedy][:timezone],
    :endpoint                     => node[:opennms][:remedy][:endpoint],
    :portname                     => node[:opennms][:remedy][:portname],
    :createendpoint               => node[:opennms][:remedy][:createendpoint],
    :createportname               => node[:opennms][:remedy][:createportname],
    :targetgroups                 => node[:opennms][:remedy][:targetgroups],
    :assignedgroups               => node[:opennms][:remedy][:assignedgroups],
    :assignedsupportcompanies     => node[:opennms][:remedy][:assignedsupportcompanies],
    :assignedsupportorganizations => node[:opennms][:remedy][:assignedsupportorganizations],
    :assignedgroup                => node[:opennms][:remedy][:assignedgroup],
    :firstname                    => node[:opennms][:remedy][:firstname],
    :lastname                     => node[:opennms][:remedy][:lastname],
    :serviceCI                    => node[:opennms][:remedy][:serviceCI],
    :serviceCIReconID             => node[:opennms][:remedy][:serviceCIReconID],
    :assignedsupportcompany       => node[:opennms][:remedy][:assignedsupportcompany],
    :assignedsupportorganization  => node[:opennms][:remedy][:assignedsupportorganization],
    :categorizationtier1          => node[:opennms][:remedy][:categorizationtier1],
    :categorizationtier2          => node[:opennms][:remedy][:categorizationtier2],
    :categorizationtier3          => node[:opennms][:remedy][:categorizationtier3],
    :service_type                 => node[:opennms][:remedy][:service_type],
    :reported_source              => node[:opennms][:remedy][:reported_source],
    :impact                       => node[:opennms][:remedy][:impact],
    :urgency                      => node[:opennms][:remedy][:urgency],
    :reason_reopen                => node[:opennms][:remedy][:reason_reopen],
    :resolution                   => node[:opennms][:remedy][:resolution],
    :reason_resolved              => node[:opennms][:remedy][:reason_resolved],
    :reason_cancelled             => node[:opennms][:remedy][:reason_cancelled]
  )
end

template "#{onms_home}/etc/reportd-configuration.xml" do
  cookbook node[:opennms][:reportd][:cookbook]
  source "reportd-configuration.xml.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :storage_location => node[:opennms][:reportd][:storage_location],
    :persist_reports  => node[:opennms][:reportd][:persist_reports]
  )
end

template "#{onms_home}/etc/response-adhoc-graph.properties" do
  cookbook node[:opennms][:response_adhoc_graph][:cookbook]
  source "response-adhoc-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :command_prefix => node[:opennms][:response_adhoc_graph][:command_prefix]
  )
end

template "#{onms_home}/etc/response-graph.properties" do
  cookbook node[:opennms][:response_graph][:cookbook]
  source "response-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :image_format        => node[:opennms][:response_graph][:image_format],
    :command_prefix      => node[:opennms][:response_graph][:command_prefix],
    :default_font_size   => node[:opennms][:response_graph][:default_font_size],
    :title_font_size     => node[:opennms][:response_graph][:title_font_size],
    :title_font_size     => node[:opennms][:response_graph][:title_font_size],
    :icmp                => node[:opennms][:response_graph][:icmp],
    :avail               => node[:opennms][:response_graph][:avail],
    :dhcp                => node[:opennms][:response_graph][:dhcp],
    :dns                 => node[:opennms][:response_graph][:dns],
    :http                => node[:opennms][:response_graph][:http],
    :http_8080           => node[:opennms][:response_graph][:http_8080],
    :http_8000           => node[:opennms][:response_graph][:http_8000],
    :mail                => node[:opennms][:response_graph][:mail],
    :pop3                => node[:opennms][:response_graph][:pop3],
    :radius              => node[:opennms][:response_graph][:radius],
    :smtp                => node[:opennms][:response_graph][:smtp],
    :ssh                 => node[:opennms][:response_graph][:ssh],
    :jboss               => node[:opennms][:response_graph][:jboss],
    :snmp                => node[:opennms][:response_graph][:snmp],
    :ldap                => node[:opennms][:response_graph][:ldap],
    :strafeping          => node[:opennms][:response_graph][:strafeping],
    :strafeping_count    => node[:opennms][:poller][:strafer][:strafeping][:ping_count],
    :strafeping_colors   => node[:opennms][:response_graph][:strafeping_colors],
    :memcached_bytes     => node[:opennms][:response_graph][:memcached_bytes],
    :memcached_bytesrw   => node[:opennms][:response_graph][:memcached_bytesrw],
    :memcached_uptime    => node[:opennms][:response_graph][:memcached_uptime],
    :memcached_rusage    => node[:opennms][:response_graph][:memcached_rusage],
    :memcached_items     => node[:opennms][:response_graph][:memcached_items],
    :memcached_conns     => node[:opennms][:response_graph][:memcached_conns],
    :memcached_tconns    => node[:opennms][:response_graph][:memcached_tconns],
    :memcached_cmds      => node[:opennms][:response_graph][:memcached_cmds],
    :memcached_gets      => node[:opennms][:response_graph][:memcached_gets],
    :memcached_evictions => node[:opennms][:response_graph][:memcached_evictions],
    :memcached_threads   => node[:opennms][:response_graph][:memcached_threads],
    :memcached_struct    => node[:opennms][:response_graph][:memcached_struct],
    :ciscoping_time      => node[:opennms][:response_graph][:ciscoping_time]
  )
end

template "#{onms_home}/etc/rrd-configuration.properties" do
  cookbook node[:opennms][:rrd][:cookbook]
  source "rrd-configuration.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :strategy_class  => node[:opennms][:rrd][:strategy_class],
    :interface_jar   => node[:opennms][:rrd][:interface_jar],
    :jrrd            => node[:opennms][:rrd][:jrrd],
    :file_extension  => node[:opennms][:rrd][:file_extension],
    :queue           => node[:opennms][:rrd][:queue],
    :jrobin          => node[:opennms][:rrd][:jrobin],
    :usetcp          => node[:opennms][:rrd][:usetcp],
    :tcp             => node[:opennms][:rrd][:tcp]
  )
end

template "#{onms_home}/etc/rtc-configuration.xml" do
  cookbook node[:opennms][:rtc][:cookbook]
  source "rtc-configuration.xml.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :updaters                      => node[:opennms][:rtc][:updaters],
    :senders                       => node[:opennms][:rtc][:senders],
    :rolling_window                => node[:opennms][:rtc][:rolling_window],
    :max_events_before_resend      => node[:opennms][:rtc][:max_events_before_resend],
    :low_threshold_interval        => node[:opennms][:rtc][:low_threshold_interval],
    :high_threshold_interval       => node[:opennms][:rtc][:high_threshold_interval],
    :user_refresh_interval         => node[:opennms][:rtc][:user_refresh_interval],
    :errors_before_url_unsubscribe => node[:opennms][:rtc][:errors_before_url_unsubscribe]
  )
end

template "#{onms_home}/etc/site-status-views.xml" do
  cookbook node[:opennms][:site_status_views][:cookbook]
  source "site-status-views.xml.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :default_view => node[:opennms][:site_status_views][:default_view]
  )
end

template "#{onms_home}/etc/snmp-adhoc-graph.properties" do
  cookbook node[:opennms][:snmp_adhoc_graph][:cookbook]
  source "snmp-adhoc-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :image_format   => node[:opennms][:snmp_adhoc_graph][:image_format],
    :command_prefix => node[:opennms][:snmp_adhoc_graph][:command_prefix]
  )
end

template "#{onms_home}/etc/snmp-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:cookbook]
  source "snmp-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :image_format        => node[:opennms][:snmp_graph][:image_format],
    :command_prefix      => node[:opennms][:snmp_graph][:command_prefix],
    :default_font_size   => node[:opennms][:snmp_graph][:default_font_size],
    :title_font_size     => node[:opennms][:snmp_graph][:title_font_size],
    :default_ksc_graph   => node[:opennms][:snmp_graph][:default_ksc_graph],
    :include_dir         => node[:opennms][:snmp_graph][:include_dir],
    :include_rescan      => node[:opennms][:snmp_graph][:include_rescan],
    :onms_queued_updates => node[:opennms][:snmp_graph][:onms_queued_updates],
    :onms_queued_pending => node[:opennms][:snmp_graph][:onms_queued_pending]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/acmepacket-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:acmepacket][:cookbook]
  source "snmp-graph.properties.d/acmepacket-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:acmepacket][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/adonis-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:adonis][:cookbook]
  source "snmp-graph.properties.d/adonis-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:adonis][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/adsl-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:adsl][:cookbook]
  source "snmp-graph.properties.d/adsl-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:adsl][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/airport-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:airport][:cookbook]
  source "snmp-graph.properties.d/airport-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:airport][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/aix-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:aix][:cookbook]
  source "snmp-graph.properties.d/aix-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:aix][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/akcp-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:akcp][:cookbook]
  source "snmp-graph.properties.d/akcp-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:akcp][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/alvarion-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:alvarion][:cookbook]
  source "snmp-graph.properties.d/alvarion-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:alvarion][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/apc-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:apc][:cookbook]
  source "snmp-graph.properties.d/apc-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:apc][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/ascend-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:ascend][:cookbook]
  source "snmp-graph.properties.d/ascend-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:ascend][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/asterisk-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:asterisk][:cookbook]
  source "snmp-graph.properties.d/asterisk-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:asterisk][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/bgp-ietf-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:bgp_ietf][:cookbook]
  source "snmp-graph.properties.d/bgp-ietf-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:bgp_ietf][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/bluecoat-sgproxy-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:bluecoat_sgproxy][:cookbook]
  source "snmp-graph.properties.d/bluecoat-sgproxy-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:bluecoat_sgproxy][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/bridgewave-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:bridgewave][:cookbook]
  source "snmp-graph.properties.d/bridgewave-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:bridgewave][:enabled]
  )
end
template "#{onms_home}/etc/snmp-graph.properties.d/brocade-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:brocade][:cookbook]
  source "snmp-graph.properties.d/brocade-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:brocade][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/ca-empire-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:ca_empire][:cookbook]
  source "snmp-graph.properties.d/ca-empire-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:ca_empire][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/checkpoint-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:checkpoint][:cookbook]
  source "snmp-graph.properties.d/checkpoint-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:checkpoint][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/cisco-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:cisco][:cookbook]
  source "snmp-graph.properties.d/cisco-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:cisco][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/ciscoNexus-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:ciscoNexus][:cookbook]
  source "snmp-graph.properties.d/ciscoNexus-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:ciscoNexus][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/clavister-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:clavister][:cookbook]
  source "snmp-graph.properties.d/clavister-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:clavister][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/colubris-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:colubris][:cookbook]
  source "snmp-graph.properties.d/colubris-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:colubris][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/cyclades-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:cyclades][:cookbook]
  source "snmp-graph.properties.d/cyclades-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:cyclades][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/dell-openmanage-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:dell_openmanage][:cookbook]
  source "snmp-graph.properties.d/dell-openmanage-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:dell_openmanage][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/dell-rac-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:dell_rac][:cookbook]
  source "snmp-graph.properties.d/dell-rac-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:dell_rac][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/dns-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:dns][:cookbook]
  source "snmp-graph.properties.d/dns-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:dns][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/ejn-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:ejn][:cookbook]
  source "snmp-graph.properties.d/ejn-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:ejn][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/equallogic-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:equallogic][:cookbook]
  source "snmp-graph.properties.d/equallogic-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:equallogic][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/ericsson-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:ericsson][:cookbook]
  source "snmp-graph.properties.d/ericsson-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:ericsson][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/extreme-networks-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:extreme_networks][:cookbook]
  source "snmp-graph.properties.d/extreme-networks-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:extreme_networks][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/f5-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:f5][:cookbook]
  source "snmp-graph.properties.d/f5-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:f5][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/force10-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:force10][:cookbook]
  source "snmp-graph.properties.d/force10-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:force10][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/fortinet-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:fortinet][:cookbook]
  source "snmp-graph.properties.d/fortinet-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:fortinet][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/foundry-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:foundry][:cookbook]
  source "snmp-graph.properties.d/foundry-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:foundry][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/framerelay-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:framerelay][:cookbook]
  source "snmp-graph.properties.d/framerelay-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:framerelay][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/host-resources-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:host_resources][:cookbook]
  source "snmp-graph.properties.d/host-resources-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:host_resources][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/hp-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:hp][:cookbook]
  source "snmp-graph.properties.d/hp-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:hp][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/hpux-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:hpux][:cookbook]
  source "snmp-graph.properties.d/hpux-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:hpux][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/hwg-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:hwg][:cookbook]
  source "snmp-graph.properties.d/hwg-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:hwg][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/ipunity-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:ipunity][:cookbook]
  source "snmp-graph.properties.d/ipunity-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:ipunity][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/jboss-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:jboss][:cookbook]
  source "snmp-graph.properties.d/jboss-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:jboss][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/juniper-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:juniper][:cookbook]
  source "snmp-graph.properties.d/juniper-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:juniper][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/jvm-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:jvm][:cookbook]
  source "snmp-graph.properties.d/jvm-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:jvm][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/liebert-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:liebert][:cookbook]
  source "snmp-graph.properties.d/liebert-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:liebert][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/lmsensors-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:lmsensors][:cookbook]
  source "snmp-graph.properties.d/lmsensors-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:lmsensors][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/mailmarshal-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:mailmarshal][:cookbook]
  source "snmp-graph.properties.d/mailmarshal-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:mailmarshal][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/mcast-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:mcast][:cookbook]
  source "snmp-graph.properties.d/mcast-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:mcast][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/mge-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:mge][:cookbook]
  source "snmp-graph.properties.d/mge-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:mge][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/mib2-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:mib2][:cookbook]
  source "snmp-graph.properties.d/mib2-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:mib2][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/microsoft-exchange-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:microsoft_exchange][:cookbook]
  source "snmp-graph.properties.d/microsoft-exchange-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:microsoft_exchange][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/microsoft-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:microsoft][:cookbook]
  source "snmp-graph.properties.d/microsoft-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:microsoft][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/microsoft-http-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:microsoft_http][:cookbook]
  source "snmp-graph.properties.d/microsoft-http-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:microsoft_http][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/microsoft-iis-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:microsoft_iis][:cookbook]
  source "snmp-graph.properties.d/microsoft-iis-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:microsoft_iis][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/microsoft-lcs-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:microsoft_lcs][:cookbook]
  source "snmp-graph.properties.d/microsoft-lcs-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:microsoft_lcs][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/microsoft-sql-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:microsoft_sql][:cookbook]
  source "snmp-graph.properties.d/microsoft-sql-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:microsoft_sql][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/microsoft-windows-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:microsoft_windows][:cookbook]
  source "snmp-graph.properties.d/microsoft-windows-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:microsoft_windows][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/microsoft-wmi-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:microsoft_wmi][:cookbook]
  source "snmp-graph.properties.d/microsoft-wmi-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:microsoft_wmi][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/mikrotik-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:mikrotik][:cookbook]
  source "snmp-graph.properties.d/mikrotik-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:mikrotik][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/mysql-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:mysql][:cookbook]
  source "snmp-graph.properties.d/mysql-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:mysql][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/netapp-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:netapp][:cookbook]
  source "snmp-graph.properties.d/netapp-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:netapp][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/netbotz-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:netbotz][:cookbook]
  source "snmp-graph.properties.d/netbotz-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:netbotz][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/netenforcer-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:netenforcer][:cookbook]
  source "snmp-graph.properties.d/netenforcer-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:netenforcer][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/netscaler-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:netscaler][:cookbook]
  source "snmp-graph.properties.d/netscaler-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:netscaler][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/netsnmp-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:netsnmp][:cookbook]
  source "snmp-graph.properties.d/netsnmp-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:netsnmp][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/nortel-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:nortel][:cookbook]
  source "snmp-graph.properties.d/nortel-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:nortel][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/novell-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:novell][:cookbook]
  source "snmp-graph.properties.d/novell-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:novell][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/pfsense-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:pfsense][:cookbook]
  source "snmp-graph.properties.d/pfsense-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:pfsense][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/postgresql-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:postgresql][:cookbook]
  source "snmp-graph.properties.d/postgresql-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:postgresql][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/riverbed-steelhead-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:riverbed_steelhead][:cookbook]
  source "snmp-graph.properties.d/riverbed-steelhead-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:riverbed_steelhead][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/servertech-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:servertech][:cookbook]
  source "snmp-graph.properties.d/servertech-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:servertech][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/snmp-informant-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:snmp_informant][:cookbook]
  source "snmp-graph.properties.d/snmp-informant-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:snmp_informant][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/sofaware-embeddedngx-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:sofaware_embeddedngx][:cookbook]
  source "snmp-graph.properties.d/sofaware-embeddedngx-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:sofaware_embeddedngx][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/sun-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:sun][:cookbook]
  source "snmp-graph.properties.d/sun-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:sun][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/trango-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:trango][:cookbook]
  source "snmp-graph.properties.d/trango-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:trango][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/vmware-cim-graph-simple.properties" do
  cookbook node[:opennms][:snmp_graph][:vmware_cim][:cookbook]
  source "snmp-graph.properties.d/vmware-cim-graph-simple.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:vmware_cim][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/vmware3-graph-simple.properties" do
  cookbook node[:opennms][:snmp_graph][:vmware3][:cookbook]
  source "snmp-graph.properties.d/vmware3-graph-simple.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:vmware3][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/vmware4-graph-simple.properties" do
  cookbook node[:opennms][:snmp_graph][:vmware4][:cookbook]
  source "snmp-graph.properties.d/vmware4-graph-simple.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:vmware4][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/vmware5-cpu-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:vmware5][:cookbook]
  source "snmp-graph.properties.d/vmware5-cpu-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:vmware5][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/vmware5-datastore-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:vmware5][:cookbook]
  source "snmp-graph.properties.d/vmware5-datastore-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:vmware5][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/vmware5-disk-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:vmware5][:cookbook]
  source "snmp-graph.properties.d/vmware5-disk-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:vmware5][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/vmware5-host-based-replication-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:vmware5][:cookbook]
  source "snmp-graph.properties.d/vmware5-host-based-replication-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:vmware5][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/vmware5-memory-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:vmware5][:cookbook]
  source "snmp-graph.properties.d/vmware5-memory-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:vmware5][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/vmware5-network-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:vmware5][:cookbook]
  source "snmp-graph.properties.d/vmware5-network-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:vmware5][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/vmware5-power-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:vmware5][:cookbook]
  source "snmp-graph.properties.d/vmware5-power-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:vmware5][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/vmware5-storage-adapter-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:vmware5][:cookbook]
  source "snmp-graph.properties.d/vmware5-storage-adapter-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:vmware5][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/vmware5-storage-path-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:vmware5][:cookbook]
  source "snmp-graph.properties.d/vmware5-storage-path-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:vmware5][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/vmware5-system-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:vmware5][:cookbook]
  source "snmp-graph.properties.d/vmware5-system-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:vmware5][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/vmware5-virtual-disk-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:vmware5][:cookbook]
  source "snmp-graph.properties.d/vmware5-virtual-disk-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:vmware5][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/xmp-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:xmp][:cookbook]
  source "snmp-graph.properties.d/xmp-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:xmp][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/xups-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:xups][:cookbook]
  source "snmp-graph.properties.d/xups-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:xups][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/zeus-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:zeus][:cookbook]
  source "snmp-graph.properties.d/zeus-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:zeus][:enabled]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/zertico-graph.properties" do
  cookbook node[:opennms][:snmp_graph][:zertico][:cookbook]
  source "snmp-graph.properties.d/zertico-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:zertico][:enabled]
  )
end

template "#{onms_home}/etc/snmp-interface-poller-configuration.xml" do
  cookbook node[:opennms][:snmp_iface_poller][:cookbook]
  source "snmp-interface-poller-configuration.xml.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :threads     => node[:opennms][:snmp_iface_poller][:threads],
    :service     => node[:opennms][:snmp_iface_poller][:service],
    :node_outage => node[:opennms][:snmp_iface_poller][:node_outage],
    :example1    => node[:opennms][:snmp_iface_poller][:example1]
  )
end

template "#{onms_home}/etc/statsd-configuration.xml" do
  cookbook node[:opennms][:statsd][:cookbook]
  source "statsd-configuration.xml.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :throughput            => node[:opennms][:statsd][:throughput],
    :response_time_reports => node[:opennms][:statsd][:response_time_reports]
  )
end

template "#{onms_home}/etc/support.properties" do
  cookbook node[:opennms][:support][:cookbook]
  source "support.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :queueid => node[:opennms][:support][:queueid],
    :timeout => node[:opennms][:support][:timeout],
    :retry   => node[:opennms][:support][:retry]
  )
end

template "#{onms_home}/etc/surveillance-views.xml" do
  cookbook node[:opennms][:surveillance_views][:cookbook]
  source "surveillance-views.xml.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :default_view => node[:opennms][:surveillance_views][:default_view],
    :default      => node[:opennms][:surveillance_views][:default]
  )
end

template "#{onms_home}/etc/jms-northbounder-configuration.xml" do
  cookbook node[:opennms][:jms_nbi][:cookbook]
  source "jms-northbounder-configuration.xml.erb"
  mode 00664
  owner 'root'
  group 'root'
  notifies :restart, 'service[opennms]'
  variables(
    :enabled => node[:opennms][:jms_nbi][:enabled],
    :nagles_delay => node[:opennms][:jms_nbi][:nagles_delay],
    :batch_size => node[:opennms][:jms_nbi][:batch_size],
    :queue_size => node[:opennms][:jms_nbi][:queue_size],
    :message_format => node[:opennms][:jms_nbi][:message_format],
    :jms_destination => node[:opennms][:jms_nbi][:jms_destination],
    :send_as_object_message => node[:opennms][:jms_nbi][:send_as_object_message],
    :first_occurence_only => node[:opennms][:jms_nbi][:first_occurence_only]
  )
end

template "#{onms_home}/etc/syslog-northbounder-configuration.xml" do
  cookbook node[:opennms][:syslog_north][:cookbook]
  source "syslog-northbounder-configuration.xml.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :use_defaults   => node[:opennms][:syslog_north][:use_defaults],
    :enabled        => node[:opennms][:syslog_north][:enabled],
    :nagles_delay   => node[:opennms][:syslog_north][:nagles_delay],
    :batch_size     => node[:opennms][:syslog_north][:batch_size],
    :queue_size     => node[:opennms][:syslog_north][:queue_size],
    :message_format => node[:opennms][:syslog_north][:message_format],
    :destination    => node[:opennms][:syslog_north][:destination],
    :uei            => node[:opennms][:syslog_north][:uei]
  )
end

template "#{onms_home}/etc/syslogd-configuration.xml" do
  cookbook node[:opennms][:syslogd][:cookbook]
  source "syslogd-configuration.xml.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :port                   => node[:opennms][:syslogd][:port],
    :new_suspect            => node[:opennms][:syslogd][:new_suspect],
    :parser                 => node[:opennms][:syslogd][:parser],
    :forwarding_regexp      => node[:opennms][:syslogd][:forwarding_regexp],
    :matching_group_host    => node[:opennms][:syslogd][:matching_group_host],
    :matching_group_message => node[:opennms][:syslogd][:matching_group_message],
    :discard_uei            => node[:opennms][:syslogd][:discard_uei],
    :apache_httpd           => node[:opennms][:syslogd][:apache_httpd],
    :linux_kernel           => node[:opennms][:syslogd][:linux_kernel],
    :openssh                => node[:opennms][:syslogd][:openssh],
    :postfix                => node[:opennms][:syslogd][:postfix],
    :procmail               => node[:opennms][:syslogd][:procmail],
    :sudo                   => node[:opennms][:syslogd][:sudo],
    :files                  => node[:opennms][:syslogd][:files]
  )
end

template "#{onms_home}/etc/threshd-configuration.xml" do
  cookbook node[:opennms][:threshd][:cookbook]
  source "threshd-configuration.xml.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :threads                 => node[:opennms][:threshd][:threads],
    :mib2                    => node[:opennms][:threshd][:mib2],
    :hrstorage               => node[:opennms][:threshd][:hrstorage],
    :cisco                   => node[:opennms][:threshd][:cisco],
    :juniper_srx             => node[:opennms][:threshd][:juniper_srx],
    :netsnmp                 => node[:opennms][:threshd][:netsnmp],
    :netsnmp_memory_linux    => node[:opennms][:threshd][:netsnmp_memory_linux],
    :netsnmp_memory_nonlinux => node[:opennms][:threshd][:netsnmp_memory_nonlinux]
  )
end

template "#{onms_home}/etc/thresholds.xml" do
  cookbook node[:opennms][:thresholds][:cookbook]
  source "thresholds.xml.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :mib2                    => node[:opennms][:thresholds][:mib2],
    :hrstorage               => node[:opennms][:thresholds][:hrstorage],
    :cisco                   => node[:opennms][:thresholds][:cisco],
    :juniper_srx             => node[:opennms][:thresholds][:juniper_srx],
    :netsnmp                 => node[:opennms][:thresholds][:netsnmp],
    :netsnmp_memory_linux    => node[:opennms][:thresholds][:netsnmp_memory_linux],
    :netsnmp_memory_nonlinux => node[:opennms][:thresholds][:netsnmp_memory_nonlinux],
    :coffee                  => node[:opennms][:thresholds][:coffee]
  )
end

template "#{onms_home}/etc/translator-configuration.xml" do
  cookbook node[:opennms][:translator][:cookbook]
  source "translator-configuration.xml.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :snmp_link_down        => node[:opennms][:translator][:snmp_link_down],
    :snmp_link_up          => node[:opennms][:translator][:snmp_link_up],
    :hyperic               => node[:opennms][:translator][:hyperic],
    :cisco_config_man      => node[:opennms][:translator][:cisco_config_man],
    :juniper_cfg_change    => node[:opennms][:translator][:juniper_cfg_change]
  )
end

template "#{onms_home}/etc/trapd-configuration.xml" do
  cookbook node[:opennms][:trapd][:cookbook]
  source "trapd-configuration.xml.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :port        => node[:opennms][:trapd][:port],
    :new_suspect => node[:opennms][:trapd][:new_suspect]
  )
end

template "#{onms_home}/etc/users.xml" do
  cookbook node[:opennms][:users][:cookbook]
  source "users.xml.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :name          => node[:opennms][:users][:admin][:name],
    :user_comments => node[:opennms][:users][:admin][:user_comments],
    :password      => node[:opennms][:users][:admin][:password]
  )
end

template "#{onms_home}/etc/vacuumd-configuration.xml" do
  cookbook node[:opennms][:vacuumd][:cookbook]
  source "vacuumd-configuration.xml.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :period        => node[:opennms][:vacuumd][:period],
    :statement     => node[:opennms][:vacuumd][:statement],
    :automations   => node[:opennms][:vacuumd][:automations],
    :triggers      => node[:opennms][:vacuumd][:triggers],
    :actions       => node[:opennms][:vacuumd][:actions],
    :auto_events   => node[:opennms][:vacuumd][:auto_events],
    :action_events => node[:opennms][:vacuumd][:action_events]
  )
end

template "#{onms_home}/etc/viewsdisplay.xml" do
  cookbook node[:opennms][:web_console_view][:cookbook]
  source "viewsdisplay.xml.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :web_console_view        => node[:opennms][:web_console_view]
  )
end

template "#{onms_home}/etc/vmware-cim-datacollection-config.xml" do
  cookbook node[:opennms][:vmware_cim][:cookbook]
  source "vmware-cim-datacollection-config.xml.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :rrd_repository         => node[:opennms][:vmware_cim][:rrd_repository],
    :default_esx_hostsystem => node[:opennms][:vmware_cim][:default_esx_hostsystem]
  )
end

template "#{onms_home}/etc/vmware-datacollection-config.xml" do
  cookbook node[:opennms][:vmware][:cookbook]
  source "vmware-datacollection-config.xml.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :rrd_repository         => node[:opennms][:vmware][:rrd_repository],
    :default_hostsystem3    => node[:opennms][:vmware][:default_hostsystem3],
    :default_vm3            => node[:opennms][:vmware][:default_vm3],
    :default_hostsystem4    => node[:opennms][:vmware][:default_hostsystem4],
    :default_vm4            => node[:opennms][:vmware][:default_vm4],
    :default_hostsystem5    => node[:opennms][:vmware][:default_hostsystem5],
    :default_vm5            => node[:opennms][:vmware][:default_vm5]
  )
end

template "#{onms_home}/etc/wmi-datacollection-config.xml" do
  cookbook node[:opennms][:wmi][:cookbook]
  source "wmi-datacollection-config.xml.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :rrd_repository => node[:opennms][:wmi][:rrd_repository],
    :default        => node[:opennms][:wmi][:default]
  )
end

template "#{onms_home}/etc/xmpp-configuration.properties" do
  cookbook node[:opennms][:xmpp][:cookbook]
  source "xmpp-configuration.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :server              => node[:opennms][:xmpp][:server],
    :service_name        => node[:opennms][:xmpp][:service_name],
    :port                => node[:opennms][:xmpp][:port],
    :tls                 => node[:opennms][:xmpp][:tls],
    :sasl                => node[:opennms][:xmpp][:sasl],
    :self_signed_certs   => node[:opennms][:xmpp][:self_signed_certs],
    :truststore_password => node[:opennms][:xmpp][:truststore_password],
    :debug               => node[:opennms][:xmpp][:debug],
    :user                => node[:opennms][:xmpp][:user],
    :pass                => node[:opennms][:xmpp][:pass]
  )
end


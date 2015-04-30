#
# Cookbook Name:: opennms
# Recipe:: default
#
# Copyright 2014, Spanlink Communications, Inc
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

include_recipe 'build-essential::default'
chef_gem 'java_properties'
chef_gem 'rest-client'

yum_repository 'opennms-stable-common' do
    description 'RPMs Common to All OpenNMS Architectures RPMs (stable)'
    baseurl node['yum']['opennms-stable-common']['baseurl']
    mirrorlist node['yum']['opennms-stable-common']['url']
    gpgkey node['yum']['opennms']['key_url']
    failovermethod node['yum']['opennms-stable-common']['failovermethod']
    includepkgs node['yum']['opennms-stable-common']['includepkgs']
    exclude node['yum']['opennms-stable-common']['exclude']
    action :create
end

yum_repository 'opennms-stable-rhel6' do
    description 'RedHat Enterprise Linux 6.x and CentOS 6.x RPMs (stable)'
    baseurl node['yum']['opennms-stable-rhel6']['baseurl']
    mirrorlist node['yum']['opennms-stable-rhel6']['url']
    gpgkey node['yum']['opennms']['key_url']
    includepkgs node['yum']['opennms-stable-rhel6']['includepkgs']
    exclude node['yum']['opennms-stable-rhel6']['exclude']
    action :create
end

fqdn = node[:fqdn]
fqdn ||= node[:hostname]

onms_home = node[:opennms][:conf][:home]
onms_home ||= '/opt/opennms'

hostsfile_entry node['ipaddress'] do
  hostname fqdn
  action [:create_if_missing, :append]
end

package ['opennms-core', 'opennms-webapp-jetty', 'opennms-docs'] do
  version [node['opennms']['version'], 
    node['opennms']['version'], node['opennms']['version']]
  allow_downgrade node['opennms']['allow_downgrade']
  action :install
end

#package "opennms-core" do
#  version node['opennms']['version']
#  action :install
#end

#package "opennms-docs" do
#  version node['opennms']['version']
#  action :install
#end

package "iplike" do
  action :install
end

package "perl-libwww-perl" do
  action :install
end
package "perl-XML-Twig" do
  action :install
end

include_recipe 'opennms::send_events'

if node['opennms']['upgrade']
  include_recipe 'opennms::upgrade'
end

execute "runjava" do
  cwd onms_home
  creates "#{onms_home}/etc/java.conf"
  command "#{onms_home}/bin/runjava -s"
end

execute "install" do
  cwd onms_home
  creates "#{onms_home}/etc/configured"
  command "#{onms_home}/bin/install -dis"
end

template "#{onms_home}/etc/opennms.conf" do
  source "opennms.conf.erb"
  mode 00664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :home                   => node[:opennms][:conf][:home],
    :pidfile                => node[:opennms][:conf][:pidfile],
    :logdir                 => node[:opennms][:conf][:logdir],
    :initdir                => node[:opennms][:conf][:initdir],
    :redirect               => node[:opennms][:conf][:redirect],
    :start_timeout          => node[:opennms][:conf][:start_timeout],
    :status_wait            => node[:opennms][:conf][:status_wait],
    :heap_size              => node[:opennms][:conf][:heap_size],
    :addl_mgr_opts          => node[:opennms][:conf][:addl_mgr_opts],
    :addl_classpath         => node[:opennms][:conf][:addl_classpath],
    :use_incgc              => node[:opennms][:conf][:use_incgc],
    :hotspot                => node[:opennms][:conf][:hotspot],
    :verbose_gc             => node[:opennms][:conf][:verbose_gc],
    :runjava_opts           => node[:opennms][:conf][:runjava_opts],
    :invoke_url             => node[:opennms][:conf][:invoke_url],
    :runas                  => node[:opennms][:conf][:runas],
    :max_file_descr         => node[:opennms][:conf][:max_file_descr],
    :max_stack_sgmt         => node[:opennms][:conf][:max_stack_sgmt],
    :command                => node[:opennms][:conf][:command]
  )
end

template "#{onms_home}/etc/jetty.xml" do
  source "jetty.xml.erb"
  mode 00664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :ajp   => node['opennms']['properties']['jetty']['ajp'],
    :https_port => node['opennms']['properties']['jetty']['https_port'],
    :https_host => node['opennms']['properties']['jetty']['https_host']
  )
end

template "#{onms_home}/etc/opennms.properties" do
  source "opennms.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :pinger_class                   => node['opennms']['properties']['icmp']['pinger_class'],
    :require_v4                     => node['opennms']['properties']['icmp']['require_v4'],
    :require_v6                     => node['opennms']['properties']['icmp']['require_v6'],
    :strategy_class                 => node['opennms']['properties']['snmp']['strategy_class'],
    :smisyntaxes                    => node['opennms']['properties']['snmp']['smisyntaxes'],
    :forward_runtime_exceptions     => node['opennms']['properties']['snmp']['forward_runtime_exceptions'],
    :log_factory                    => node['opennms']['properties']['snmp']['log_factory'],
    :allow_64bit_ipaddress          => node['opennms']['properties']['snmp']['allow_64bit_ipaddress'],
    :no_getbulk                     => node['opennms']['properties']['snmp']['no_getbulk'],
    :allow_snmpv2_in_v1             => node['opennms']['properties']['snmp']['allow_snmpv2_in_v1'],
    :store_by_group                 => node['opennms']['properties']['dc']['store_by_group'],
    :store_by_foreign_source        => node['opennms']['properties']['dc']['store_by_foreign_source'],
    :rrd_base_dir                   => node['opennms']['properties']['dc']['rrd_base_dir'],
    :rrd_binary                     => node['opennms']['properties']['dc']['rrd_binary'],
    :decimal_format                 => node['opennms']['properties']['dc']['decimal_format'],
    :reload_check_interval          => node['opennms']['properties']['dc']['reload_check_interval'],
    :instrumentation_class          => node['opennms']['properties']['dc']['instrumentation_class'],
    :enable_check_file_mod          => node['opennms']['properties']['dc']['enable_check_file_mod'],
    :force_rescan                   => node['opennms']['properties']['dc']['force_rescan'],
    :instance_limiting              => node['opennms']['properties']['dc']['instance_limiting'],
    :rmi_server_hostname            => node['opennms']['properties']['remote']['rmi_server_hostname'],
    :exclude_service_monitors       => node['opennms']['properties']['remote']['exclude_service_monitors'],
    :min_config_reload_int          => node['opennms']['properties']['remote']['min_config_reload_int'],
    :pb_disconnect_timeout          => node['opennms']['properties']['remote']['pb_disconnect_timeout'],
    :pb_server_port                 => node['opennms']['properties']['remote']['pb_server_port'],
    :pb_registry_port               => node['opennms']['properties']['remote']['pb_registry_port'],
    :servicelayer                   => node['opennms']['properties']['ticket']['servicelayer'],
    :plugin                         => node['opennms']['properties']['ticket']['plugin'],
    :enabled                        => node['opennms']['properties']['ticket']['enabled'],
    :link_template                  => node['opennms']['properties']['ticket']['link_template'],
    :layout_applications_vertically => node['opennms']['properties']['misc']['layout_applications_vertically'],
    :bin_dir                        => node['opennms']['properties']['misc']['bin_dir'],
    :webapp_logs_dir                => node['opennms']['properties']['misc']['webapp_logs_dir'],
    :headless                       => node['opennms']['properties']['misc']['headless'],
    :find_by_service_type_query     => node['opennms']['properties']['misc']['find_by_service_type_query'],
    :load_snmp_data_on_init         => node['opennms']['properties']['misc']['load_snmp_data_on_init'],
    :allow_html_fields              => node['opennms']['properties']['misc']['allow_html_fields'],
    :template_dir                   => node['opennms']['properties']['reporting']['template_dir'],
    :report_dir                     => node['opennms']['properties']['reporting']['report_dir'],
    :report_logo                    => node['opennms']['properties']['reporting']['report_logo'],
    :ksc_graphs_per_line            => node['opennms']['properties']['reporting']['ksc_graphs_per_line'],
    :jasper_version                 => node['opennms']['properties']['reporting']['jasper_version'],
    :proxy_host                     => node['opennms']['properties']['eventd']['proxy_host'],
    :proxy_port                     => node['opennms']['properties']['eventd']['proxy_port'],
    :proxy_timeout                  => node['opennms']['properties']['eventd']['proxy_timeout'],
    :rancid_enabled                 => node['opennms']['properties']['rancid']['enabled'],
    :only_rancid_adapter            => node['opennms']['properties']['rancid']['only_rancid_adapter'],
    :rtc_baseurl                    => node['opennms']['properties']['rtc']['baseurl'],
    :rtc_username                   => node['opennms']['properties']['rtc']['username'],
    :rtc_password                   => node['opennms']['properties']['rtc']['password'],
    :map_baseurl                    => node['opennms']['properties']['map']['baseurl'],
    :map_username                   => node['opennms']['properties']['map']['username'],
    :map_password                   => node['opennms']['properties']['map']['password'],
    :jetty_port                     => node['opennms']['properties']['jetty']['port'],
    :ajp                            => node['opennms']['properties']['jetty']['ajp'],
    :jetty_host                     => node['opennms']['properties']['jetty']['host'],
    :req_logging                    => node['opennms']['properties']['jetty']['req_logging'],
    :max_form_content_size          => node['opennms']['properties']['jetty']['max_form_content_size'],
    :request_header_size            => node['opennms']['properties']['jetty']['request_header_size'],
    :max_form_keys                  => node['opennms']['properties']['jetty']['max_form_keys'],
    :https_port                     => node['opennms']['properties']['jetty']['https_port'],
    :https_host                     => node['opennms']['properties']['jetty']['https_host'],
    :onms_home                      => node['opennms']['conf']['home'],
    :keystore                       => node['opennms']['properties']['jetty']['keystore'],
    :ks_password                    => node['opennms']['properties']['jetty']['ks_password'],
    :key_password                   => node['opennms']['properties']['jetty']['key_password'],
    :cert_alias                     => node['opennms']['properties']['jetty']['cert_alias'],
    :exclude_cipher_suites          => node['opennms']['properties']['jetty']['exclude_cipher_suites'],
    :https_baseurl                  => node['opennms']['properties']['jetty']['https_baseurl'],
    :acls                           => node['opennms']['properties']['ui']['acls'],
    :ack                            => node['opennms']['properties']['ui']['ack'],
    :show_count                     => node['opennms']['properties']['ui']['show_count'],
    :show_outage_nodes              => node['opennms']['properties']['ui']['show_outage_nodes'],
    :show_problem_nodes             => node['opennms']['properties']['ui']['show_problem_nodes'],
    :outage_node_count              => node['opennms']['properties']['ui']['outage_node_count'],
    :problem_node_count             => node['opennms']['properties']['ui']['problem_node_count'],
    :show_node_status_bar           => node['opennms']['properties']['ui']['show_node_status_bar'],
    :disable_login_success_event    => node['opennms']['properties']['ui']['disable_login_success_event'],
    :center_url                     => node['opennms']['properties']['ui']['center_url'],
    :asterisk_listen_address        => node['opennms']['properties']['asterisk']['listen_address'],
    :asterisk_listen_port           => node['opennms']['properties']['asterisk']['listen_port'],
    :max_pool_size                  => node['opennms']['properties']['asterisk']['max_pool_size'],
    :dns_server                     => node['opennms']['properties']['provisioning']['dns_server'],
    :max_concurrent_xtn             => node['opennms']['properties']['provisioning']['max_concurrent_xtn'],
    :enable_discovery               => node['opennms']['properties']['provisioning']['enable_discovery'],
    :enable_deletions               => node['opennms']['properties']['provisioning']['enable_deletions'],
    :schedule_existing_rescans      => node['opennms']['properties']['provisioning']['schedule_existing_rescans'],
    :schedule_updated_rescans       => node['opennms']['properties']['provisioning']['schedule_updated_rescans'],
    :serial_ports                   => node['opennms']['properties']['sms']['serial_ports'],
    :polling                        => node['opennms']['properties']['sms']['polling'],
    :map_type                       => node['opennms']['properties']['geo']['map_type'],
    :api_key                        => node['opennms']['properties']['geo']['api_key'],
    :geocoder_class                 => node['opennms']['properties']['geo']['geocoder_class'],
    :rate                           => node['opennms']['properties']['geo']['rate'],
    :referrer                       => node['opennms']['properties']['geo']['referrer'],
    :min_quality                    => node['opennms']['properties']['geo']['min_quality'],
    :email                          => node['opennms']['properties']['geo']['email'],
    :tile_url                       => node['opennms']['properties']['geo']['tile_url']
  )
end

template "#{onms_home}/etc/availability-reports.xml" do
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
    :xmlrpcd     => node['opennms']['services']['xmlrpcd'],
    :xmlrpc_prov => node['opennms']['services']['xmlrpc_prov'],
    :asterisk_gw => node['opennms']['services']['asterisk_gw'],
    :apm         => node['opennms']['services']['apm']
  )
end

# Disabled by default and deprecated in 1.12. You've been warned.
template "#{onms_home}/etc/capsd-configuration.xml" do
  source "capsd-configuration.xml.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :rescan_frequency      => node['opennms']['capsd']['rescan_frequency'],
    :initial_sleep_time    => node['opennms']['capsd']['initial_sleep_time'],
    :max_suspect_threads   => node['opennms']['capsd']['max_suspect_threads'],
    :max_rescan_threads    => node['opennms']['capsd']['max_rescan_threads'],
    :protocol_plugins      => node['opennms']['capsd']['protocol_plugins'],
    :icmp                  => node['opennms']['capsd']['icmp'],
    :strafeping            => node['opennms']['capsd']['strafeping'],
    :snmp                  => node['opennms']['capsd']['snmp'],
    :http                  => node['opennms']['capsd']['http'],
    :http_8080             => node['opennms']['capsd']['http_8080'],
    :http_8000             => node['opennms']['capsd']['http_8000'],
    :https                 => node['opennms']['capsd']['https'],
    :hyperic_agent         => node['opennms']['capsd']['hyperic_agent'],
    :hyperichq             => node['opennms']['capsd']['hyperichq'],
    :ftp                   => node['opennms']['capsd']['ftp'],
    :telnet                => node['opennms']['capsd']['telnet'],
    :dns                   => node['opennms']['capsd']['dns'],
    :imap                  => node['opennms']['capsd']['imap'],
    :msexchange            => node['opennms']['capsd']['msexchange'],
    :smtp                  => node['opennms']['capsd']['smtp'],
    :pop3                  => node['opennms']['capsd']['pop3'],
    :ssh                   => node['opennms']['capsd']['ssh'],
    :mysql                 => node['opennms']['capsd']['mysql'],
    :sqlserver             => node['opennms']['capsd']['sqlserver'],
    :oracle                => node['opennms']['capsd']['oracle'],
    :postgres              => node['opennms']['capsd']['postgres'],
    :router                => node['opennms']['capsd']['router'],
    :hp_insight_manager    => node['opennms']['capsd']['hp_insight_manager'],
    :dell_openmanage       => node['opennms']['capsd']['dell_openmanage'],
    :nrpe                  => node['opennms']['capsd']['nrpe'],
    :nrpe_nossl            => node['opennms']['capsd']['nrpe_nossl'],
    :windows_task_scheduler => node['opennms']['capsd']['windows_task_scheduler'],
    :opennms_jvm           => node['opennms']['capsd']['opennms_jvm']
  )
end

template "#{onms_home}/etc/categories.xml" do
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
  source "datacollection-config.xml.erb"
  mode 0644
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
    :microtik     => node['opennms']['datacollection']['default']['mikrotik'],
    :netapp       => node['opennms']['datacollection']['default']['netapp'],
    :netbotz      => node['opennms']['datacollection']['default']['netbotz'],
    :netenforcer  => node['opennms']['datacollection']['default']['netenforcer'],
    :netscalar    => node['opennms']['datacollection']['default']['netscaler'],
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
    :zeus         => node['opennms']['datacollection']['default']['zeus'],
    :vmware3      => node['opennms']['datacollection']['default']['vmware3'],
    :vmware4      => node['opennms']['datacollection']['default']['vmware4'],
    :vmware5      => node['opennms']['datacollection']['default']['vmware5'],
    :vmwarecim    => node['opennms']['datacollection']['default']['vmwarecim'],
    :ejn          => node['opennms']['datacollection']['ejn']
  )
end

template "#{onms_home}/etc/discovery-configuration.xml" do
  source "discovery-configuration.xml.erb"
  mode 0644
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
  source "enlinkd-configuration.xml.erb"
  mode 0644
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
  source "jmx-datacollection-config.xml.erb"
  mode 00664
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
  source "modemConfig.properties.erb"
  mode 00664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :modem => node[:opennms][:modem],
    :custom_modem => node[:opennms][:custom_modem]
  )
end

template "#{onms_home}/etc/notifd-configuration.xml" do
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

template "#{onms_home}/etc/snmp-graph.properties.d/3gpp.properties" do
  source "snmp-graph.properties.d/3gpp.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:threegpp]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/acmepacket-graph.properties" do
  source "snmp-graph.properties.d/acmepacket-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:acmepacket]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/adonis-graph.properties" do
  source "snmp-graph.properties.d/adonis-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:adonis]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/adsl-graph.properties" do
  source "snmp-graph.properties.d/adsl-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:adsl]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/airport-graph.properties" do
  source "snmp-graph.properties.d/airport-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:airport]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/aix-graph.properties" do
  source "snmp-graph.properties.d/aix-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:aix]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/akcp-graph.properties" do
  source "snmp-graph.properties.d/akcp-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:akcp]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/alvarion-graph.properties" do
  source "snmp-graph.properties.d/alvarion-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:alvarion]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/apc-graph.properties" do
  source "snmp-graph.properties.d/apc-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:apc]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/ascend-graph.properties" do
  source "snmp-graph.properties.d/ascend-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:ascend]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/asterisk-graph.properties" do
  source "snmp-graph.properties.d/asterisk-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:asterisk]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/bgp-ietf-graph.properties" do
  source "snmp-graph.properties.d/bgp-ietf-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:bgp_ietf]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/bluecoat-sgproxy-graph.properties" do
  source "snmp-graph.properties.d/bluecoat-sgproxy-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:bluecoat_sgproxy]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/brocade-graph.properties" do
  source "snmp-graph.properties.d/brocade-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:brocade]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/ca-empire-graph.properties" do
  source "snmp-graph.properties.d/ca-empire-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:ca_empire]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/checkpoint-graph.properties" do
  source "snmp-graph.properties.d/checkpoint-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:checkpoint]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/cisco-graph.properties" do
  source "snmp-graph.properties.d/cisco-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:cisco]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/ciscoNexus-graph.properties" do
  source "snmp-graph.properties.d/ciscoNexus-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:ciscoNexus]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/clavister-graph.properties" do
  source "snmp-graph.properties.d/clavister-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:clavister]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/colubris-graph.properties" do
  source "snmp-graph.properties.d/colubris-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:colubris]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/cyclades-graph.properties" do
  source "snmp-graph.properties.d/cyclades-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:cyclades]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/dell-openmanage-graph.properties" do
  source "snmp-graph.properties.d/dell-openmanage-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:dell_openmanage]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/dell-rac-graph.properties" do
  source "snmp-graph.properties.d/dell-rac-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:dell_rac]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/dns-graph.properties" do
  source "snmp-graph.properties.d/dns-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:dns]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/ejn-graph.properties" do
  source "snmp-graph.properties.d/ejn-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:ejn]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/equallogic-graph.properties" do
  source "snmp-graph.properties.d/equallogic-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:equallogic]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/ericsson-graph.properties" do
  source "snmp-graph.properties.d/ericsson-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:ericsson]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/extreme-networks-graph.properties" do
  source "snmp-graph.properties.d/extreme-networks-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:extreme_networks]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/f5-graph.properties" do
  source "snmp-graph.properties.d/f5-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:f5]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/force10-graph.properties" do
  source "snmp-graph.properties.d/force10-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:force10]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/fortinet-graph.properties" do
  source "snmp-graph.properties.d/fortinet-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:fortinet]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/foundry-graph.properties" do
  source "snmp-graph.properties.d/foundry-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:foundry]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/framerelay-graph.properties" do
  source "snmp-graph.properties.d/framerelay-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:framerelay]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/host-resources-graph.properties" do
  source "snmp-graph.properties.d/host-resources-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:host_resources]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/hp-graph.properties" do
  source "snmp-graph.properties.d/hp-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:hp]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/hpux-graph.properties" do
  source "snmp-graph.properties.d/hpux-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:hpux]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/hwg-graph.properties" do
  source "snmp-graph.properties.d/hwg-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:hwg]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/ipunity-graph.properties" do
  source "snmp-graph.properties.d/ipunity-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:ipunity]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/jboss-graph.properties" do
  source "snmp-graph.properties.d/jboss-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:jboss]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/juniper-graph.properties" do
  source "snmp-graph.properties.d/juniper-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:juniper]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/jvm-graph.properties" do
  source "snmp-graph.properties.d/jvm-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:jvm]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/liebert-graph.properties" do
  source "snmp-graph.properties.d/liebert-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:liebert]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/lmsensors-graph.properties" do
  source "snmp-graph.properties.d/lmsensors-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:lmsensors]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/mailmarshal-graph.properties" do
  source "snmp-graph.properties.d/mailmarshal-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:mailmarshal]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/mcast-graph.properties" do
  source "snmp-graph.properties.d/mcast-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:mcast]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/mge-graph.properties" do
  source "snmp-graph.properties.d/mge-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:mge]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/mib2-graph.properties" do
  source "snmp-graph.properties.d/mib2-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:mib2]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/microsoft-exchange-graph.properties" do
  source "snmp-graph.properties.d/microsoft-exchange-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:microsoft_exchange]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/microsoft-graph.properties" do
  source "snmp-graph.properties.d/microsoft-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:microsoft]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/microsoft-http-graph.properties" do
  source "snmp-graph.properties.d/microsoft-http-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:microsoft_http]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/microsoft-iis-graph.properties" do
  source "snmp-graph.properties.d/microsoft-iis-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:microsoft_iis]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/microsoft-lcs-graph.properties" do
  source "snmp-graph.properties.d/microsoft-lcs-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:microsoft_lcs]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/microsoft-sql-graph.properties" do
  source "snmp-graph.properties.d/microsoft-sql-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:microsoft_sql]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/microsoft-windows-graph.properties" do
  source "snmp-graph.properties.d/microsoft-windows-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:microsoft_windows]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/microsoft-wmi-graph.properties" do
  source "snmp-graph.properties.d/microsoft-wmi-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:microsoft_wmi]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/mikrotik-graph.properties" do
  source "snmp-graph.properties.d/mikrotik-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:mikrotik]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/mysql-graph.properties" do
  source "snmp-graph.properties.d/mysql-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:mysql]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/netapp-graph.properties" do
  source "snmp-graph.properties.d/netapp-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:netapp]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/netbotz-graph.properties" do
  source "snmp-graph.properties.d/netbotz-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:netbotz]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/netenforcer-graph.properties" do
  source "snmp-graph.properties.d/netenforcer-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:netenforcer]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/netscaler-graph.properties" do
  source "snmp-graph.properties.d/netscaler-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:netscaler]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/netsnmp-graph.properties" do
  source "snmp-graph.properties.d/netsnmp-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:netsnmp]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/nortel-graph.properties" do
  source "snmp-graph.properties.d/nortel-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:nortel]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/novell-graph.properties" do
  source "snmp-graph.properties.d/novell-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:novell]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/pfsense-graph.properties" do
  source "snmp-graph.properties.d/pfsense-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:pfsense]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/postgresql-graph.properties" do
  source "snmp-graph.properties.d/postgresql-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:postgresql]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/riverbed-steelhead-graph.properties" do
  source "snmp-graph.properties.d/riverbed-steelhead-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:riverbed_steelhead]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/servertech-graph.properties" do
  source "snmp-graph.properties.d/servertech-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:servertech]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/snmp-informant-graph.properties" do
  source "snmp-graph.properties.d/snmp-informant-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:snmp_informant]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/sofaware-embeddedngx-graph.properties" do
  source "snmp-graph.properties.d/sofaware-embeddedngx-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:sofaware_embeddedngx]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/sun-graph.properties" do
  source "snmp-graph.properties.d/sun-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:sun]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/trango-graph.properties" do
  source "snmp-graph.properties.d/trango-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:trango]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/vmware-cim-graph-simple.properties" do
  source "snmp-graph.properties.d/vmware-cim-graph-simple.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:vmware_cim]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/vmware3-graph-simple.properties" do
  source "snmp-graph.properties.d/vmware3-graph-simple.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:vmware3]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/vmware4-graph-simple.properties" do
  source "snmp-graph.properties.d/vmware4-graph-simple.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:vmware4]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/vmware5-cpu-graph.properties" do
  source "snmp-graph.properties.d/vmware5-cpu-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:vmware5]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/vmware5-datastore-graph.properties" do
  source "snmp-graph.properties.d/vmware5-datastore-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:vmware5]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/vmware5-disk-graph.properties" do
  source "snmp-graph.properties.d/vmware5-disk-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:vmware5]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/vmware5-host-based-replication-graph.properties" do
  source "snmp-graph.properties.d/vmware5-host-based-replication-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:vmware5]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/vmware5-memory-graph.properties" do
  source "snmp-graph.properties.d/vmware5-memory-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:vmware5]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/vmware5-network-graph.properties" do
  source "snmp-graph.properties.d/vmware5-network-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:vmware5]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/vmware5-power-graph.properties" do
  source "snmp-graph.properties.d/vmware5-power-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:vmware5]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/vmware5-storage-adapter-graph.properties" do
  source "snmp-graph.properties.d/vmware5-storage-adapter-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:vmware5]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/vmware5-storage-path-graph.properties" do
  source "snmp-graph.properties.d/vmware5-storage-path-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:vmware5]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/vmware5-system-graph.properties" do
  source "snmp-graph.properties.d/vmware5-system-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:vmware5]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/vmware5-virtual-disk-graph.properties" do
  source "snmp-graph.properties.d/vmware5-virtual-disk-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:vmware5]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/xmp-graph.properties" do
  source "snmp-graph.properties.d/xmp-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:xmp]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/xups-graph.properties" do
  source "snmp-graph.properties.d/xups-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:xups]
  )
end

template "#{onms_home}/etc/snmp-graph.properties.d/zeus-graph.properties" do
  source "snmp-graph.properties.d/zeus-graph.properties.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enabled => node[:opennms][:snmp_graph][:zeus]
  )
end

template "#{onms_home}/etc/snmp-interface-poller-configuration.xml" do
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

template "#{onms_home}/etc/syslog-northbounder-configuration.xml" do
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
    :netsnmp                 => node[:opennms][:threshd][:netsnmp],
    :netsnmp_memory_linux    => node[:opennms][:threshd][:netsnmp_memory_linux],
    :netsnmp_memory_nonlinux => node[:opennms][:threshd][:netsnmp_memory_nonlinux]
  )
end

template "#{onms_home}/etc/thresholds.xml" do
  source "thresholds.xml.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :mib2                    => node[:opennms][:thresholds][:mib2],
    :hrstorage               => node[:opennms][:thresholds][:hrstorage],
    :cisco                   => node[:opennms][:thresholds][:cisco],
    :netsnmp                 => node[:opennms][:thresholds][:netsnmp],
    :netsnmp_memory_linux    => node[:opennms][:thresholds][:netsnmp_memory_linux],
    :netsnmp_memory_nonlinux => node[:opennms][:thresholds][:netsnmp_memory_nonlinux],
    :coffee                  => node[:opennms][:thresholds][:coffee]
  )
end

template "#{onms_home}/etc/translator-configuration.xml" do
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

template "#{onms_home}/etc/xmlrpcd-configuration.xml" do
  source "xmlrpcd-configuration.xml.erb"
  mode 0664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :max_event_queue_size => node[:opennms][:xmlrpcd][:max_event_queue_size],
    :external_servers     => node[:opennms][:xmlrpcd][:external_servers],
    :base_events          => node[:opennms][:xmlrpcd][:base_events]
  )
end

template "#{onms_home}/etc/xmpp-configuration.properties" do
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

service "opennms" do
  supports :status => true, :restart => true
  action [ :enable]#, :start ]
end

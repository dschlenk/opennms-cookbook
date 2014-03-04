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

package "opennms" do
  version "1.12.5-1"
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

execute "runjava" do
  cwd onms_home
  creates "#{onms_home}/etc/java.conf"
  command "#{onms_home}/bin/runjava -S /usr/java/latest/bin/java"
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
    :max_size_stack_segment => node[:opennms][:conf][:command]
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
    :max_form_content_size          => node['opennms']['properties']['jetty']['max_form_content_size'],
    :request_header_size            => node['opennms']['properties']['jetty']['request_header_size'],
    :max_form_keys                  => node['opennms']['properties']['jetty']['max_form_keys'],
    :https_port                     => node['opennms']['properties']['jetty']['https_port'],
    :https_host                     => node['opennms']['properties']['jetty']['https_host'],
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

template "#{onms_home}/etc/access-point-monitor-configuration.xml" do
  source "access-point-monitor-configuration.xml.erb"
  mode 00664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :threads        => node[:opennms][:apm][:threads],
    :pscan_interval => node[:opennms][:apm][:pscan_interval],
    :aruba_enable   => node[:opennms][:apm][:aruba_enable],
    :moto_enable    => node[:opennms][:apm][:moto_enable]
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

# Disabled by default and deprecated in 1.12. You've been warned.
template "/opt/opennms/etc/capsd-configuration.xml" do
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
    :rrd_dc_dir   => node['opennms']['properties']['dc']['rrd_base_dir'],
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
    :timeout          => node['opennms']['discovery']['timeout']
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

template "#{onms_home}/etc/events-archiver-configuration.xml" do
  source "events-archiver-configuration.xml.erb"
  mode 00664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :age       => node['opennms']['events_archiver']['age'],
    :separator => node['opennms']['events_archiver']['separator']
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
    :enable_default     => node[:opennms][:jdbc_dc][:enable_default],
    :enable_mysql_stats => node[:opennms][:jdbc_dc][:enable_mysql_stats],
    :enable_pgsql_stats => node[:opennms][:jdbc_dc][:enable_pgsql_stats]
  )
end

template "#{onms_home}/etc/jmx-datacollection-config.xml" do
  source "jmx-datacollection-config.xml.erb"
  mode 00664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :enable_jboss   => node[:opennms][:jdbc_dc][:enable_default],
    :enable_opennms => node[:opennms][:jdbc_dc][:enable_mysql_stats]
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

template "#{onms_home}/etc/log4j.properties" do
  source "log4j.properties.erb"
  mode 00664
  owner "root"
  group "root"
  notifies :restart, "service[opennms]"
  variables(
    :stds                => node[:opennms][:log4j][:stds],
    :uncategorized       => node[:opennms][:log4j][:uncategorized],
    :misc                => node[:opennms][:log4j][:misc],
    :hibernate           => node[:opennms][:log4j][:hibernate],
    :spring              => node[:opennms][:log4j][:spring],
    :provisiond          => node[:opennms][:log4j][:provisiond],
    :pinger              => node[:opennms][:log4j][:pinger],
    :reportd             => node[:opennms][:log4j][:reportd],
    :ticketer            => node[:opennms][:log4j][:ticketer],
    :eventd              => node[:opennms][:log4j][:eventd],
    :alarmd              => node[:opennms][:log4j][:alarmd],
    :ackd                => node[:opennms][:log4j][:ackd],
    :discovery           => node[:opennms][:log4j][:discovery],
    :capsd               => node[:opennms][:log4j][:capsd],
    :notifd              => node[:opennms][:log4j][:notifd],
    :poller              => node[:opennms][:log4j][:poller],
    :snmpinterfacepoller => node[:opennms][:log4j][:snmpinterfacepoller],
    :collectd            => node[:opennms][:log4j][:collectd],
    :correlation         => node[:opennms][:log4j][:correlation],
    :drools              => node[:opennms][:log4j][:drools],
    :passive             => node[:opennms][:log4j][:passive],
    :threshd             => node[:opennms][:log4j][:threshd],
    :trapd               => node[:opennms][:log4j][:trapd],
    :actiond             => node[:opennms][:log4j][:actiond],
    :scriptd             => node[:opennms][:log4j][:scriptd],
    :rtc                 => node[:opennms][:log4j][:rtc],
    :rtcdata             => node[:opennms][:log4j][:rtcdata],
    :outage              => node[:opennms][:log4j][:outage],
    :translator          => node[:opennms][:log4j][:translator],
    :vacuum              => node[:opennms][:log4j][:vacuum],
    :manager             => node[:opennms][:log4j][:manager],
    :queued              => node[:opennms][:log4j][:queued],
    :jetty               => node[:opennms][:log4j][:jetty],
    :web                 => node[:opennms][:log4j][:web],
    :webauth             => node[:opennms][:log4j][:webauth],
    :web_rtc             => node[:opennms][:log4j][:web_rtc],
    :tomcat_internal     => node[:opennms][:log4j][:tomcat_internal],
    :dhcpd               => node[:opennms][:log4j][:dhcpd],
    :vulnscand           => node[:opennms][:log4j][:vulnscand],
    :syslogd             => node[:opennms][:log4j][:syslogd],
    :xmlrpcd             => node[:opennms][:log4j][:xmlrpcd],
    :report              => node[:opennms][:log4j][:report],
    :vmware              => node[:opennms][:log4j][:vmware],
    :rancid              => node[:opennms][:log4j][:rancid],
    :jmx                 => node[:opennms][:log4j][:jmx],
    :linkd               => node[:opennms][:log4j][:linkd],
    :web_map             => node[:opennms][:log4j][:web_map],
    :statsd              => node[:opennms][:log4j][:statsd],
    :instrumentation     => node[:opennms][:log4j][:instrumentation],
    :snmp4j_internal     => node[:opennms][:log4j][:snmp4j_internal],
    :tl1d                => node[:opennms][:log4j][:tl1d],
    :asterisk            => node[:opennms][:log4j][:asterisk],
    :insproxy            => node[:opennms][:log4j][:insproxy],
    :accesspointmonitor  => node[:opennms][:log4j][:accesspointmonitor]
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

service "opennms" do
  supports :status => true, :restart => true
  action [ :enable, :start ]
end

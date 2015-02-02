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

package "opennms-webapp-jetty" do
  version node['opennms']['version']
  timeout 1200
  action :install
end

package "opennms-core" do
  version node['opennms']['version']
  timeout 1200
  action :install
end

package "opennms-docs" do
  version node['opennms']['version']
  timeout 1200
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
    :addl_handlers => node['opennms']['addl_handlers'],
    :ajp   => node['opennms']['properties']['jetty']['ajp'],
    :https_port => node['opennms']['properties']['jetty']['https_port'],
    :https_host => node['opennms']['properties']['jetty']['https_host'],
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

service "opennms" do
  supports :status => true, :restart => true
  action [ :enable]#, :start ]
end

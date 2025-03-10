#
# Cookbook:: opennms
# Recipe:: templates
#
# Copyright:: 2015-2024, ConvergeOne Holding Corp.
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

onms_home = node['opennms']['conf']['home']
onms_home ||= '/opt/opennms'

template "#{onms_home}/etc/availability-reports.xml" do
  cookbook node['opennms']['db_reports']['avail']['cookbook']
  source 'availability-reports.xml.erb'
  mode '0664'
  owner node['opennms']['username']
  group node['opennms']['groupname']
  variables(
    cal_logo: node['opennms']['db_reports']['avail']['cal']['logo'],
    cal_interval: node['opennms']['db_reports']['avail']['cal']['endDate']['interval'],
    cal_count: node['opennms']['db_reports']['avail']['cal']['endDate']['count'],
    cal_hours: node['opennms']['db_reports']['avail']['cal']['endDate']['hours'],
    cal_minutes: node['opennms']['db_reports']['avail']['cal']['endDate']['minutes'],
    classic_logo: node['opennms']['db_reports']['avail']['classic']['logo'],
    classic_interval: node['opennms']['db_reports']['avail']['classic']['endDate']['interval'],
    classic_count: node['opennms']['db_reports']['avail']['classic']['endDate']['count'],
    classic_hours: node['opennms']['db_reports']['avail']['classic']['endDate']['hours'],
    classic_minutes: node['opennms']['db_reports']['avail']['classic']['endDate']['minutes'],
    onms_home: onms_home
  )
  action node['opennms']['templates'] ? :create : :nothing
end

template "#{onms_home}/etc/service-configuration.xml" do
  cookbook node['opennms']['services']['cookbook']
  source 'service-configuration.xml.erb'
  mode '0664'
  owner node['opennms']['username']
  group node['opennms']['groupname']
  notifies :restart, 'service[opennms]'
  variables(
    snmp_poller: node['opennms']['services']['snmp_poller'],
    correlator: node['opennms']['services']['correlator'],
    tl1d: node['opennms']['services']['tl1d'],
    syslogd: node['opennms']['services']['syslogd'],
    asterisk_gw: node['opennms']['services']['asterisk_gw']
  )
  action node['opennms']['templates'] ? :create : :nothing
end

template "#{onms_home}/etc/chart-configuration.xml" do
  cookbook node['opennms']['chart']['cookbook']
  source 'chart-configuration.xml.erb'
  mode '0664'
  owner node['opennms']['username']
  group node['opennms']['groupname']
  notifies :restart, 'service[opennms]'
  variables(
    severity_enable: node['opennms']['chart']['severity_enable'],
    outages_enable: node['opennms']['chart']['outages_enable'],
    inventory_enable: node['opennms']['chart']['inventory_enable']
  )
  action node['opennms']['templates'] ? :create : :nothing
end

template "#{onms_home}/etc/nsclient-datacollection-config.xml" do
  cookbook node['opennms']['nsclient_datacollection']['cookbook']
  source 'nsclient-datacollection-config.xml.erb'
  mode '0664'
  owner node['opennms']['username']
  group node['opennms']['groupname']
  notifies :restart, 'service[opennms]'
  variables(
    rrd_repository: node['opennms']['nsclient_datacollection']['rrd_repository'],
    enable_default: node['opennms']['nsclient_datacollection']['enable_default'],
    default: node['opennms']['nsclient_datacollection']['default'],
    processor: node['opennms']['nsclient_datacollection']['default']['processor'],
    system: node['opennms']['nsclient_datacollection']['default']['system'],
    iis: node['opennms']['nsclient_datacollection']['default']['iis'],
    exchange: node['opennms']['nsclient_datacollection']['default']['exchange'],
    dns: node['opennms']['nsclient_datacollection']['default']['dns'],
    sqlserver: node['opennms']['nsclient_datacollection']['default']['sqlserver'],
    biztalk: node['opennms']['nsclient_datacollection']['default']['biztalk'],
    live: node['opennms']['nsclient_datacollection']['default']['live'],
    mailmarshal: node['opennms']['nsclient_datacollection']['default']['mailmarshal']
  )
  only_if { node['opennms']['plugin']['nsclient'] }
  action node['opennms']['templates'] ? :create : :nothing
end

template "#{onms_home}/etc/enlinkd-configuration.xml" do
  cookbook node['opennms']['enlinkd']['cookbook']
  source 'enlinkd-configuration.xml.erb'
  mode '0664'
  owner node['opennms']['username']
  group node['opennms']['groupname']
  notifies :restart, 'service[opennms]'
  variables(
    threads: node['opennms']['enlinkd']['threads'],
    executor_queue_size: node['opennms']['enlinkd']['executor_queue_size'],
    executor_threads: node['opennms']['enlinkd']['executor_threads'],
    init_sleep_time: node['opennms']['enlinkd']['init_sleep_time'],
    cdp: node['opennms']['enlinkd']['cdp'],
    cdp_interval: node['opennms']['enlinkd']['cdp_interval'],
    cdp_priority: node['opennms']['enlinkd']['cdp_priority'],
    bridge: node['opennms']['enlinkd']['bridge'],
    bridge_interval: node['opennms']['enlinkd']['bridge_interval'],
    bridge_priority: node['opennms']['enlinkd']['bridge_priority'],
    lldp: node['opennms']['enlinkd']['lldp'],
    lldp_interval: node['opennms']['enlinkd']['lldp_interval'],
    lldp_priority: node['opennms']['enlinkd']['lldp_priority'],
    ospf: node['opennms']['enlinkd']['ospf'],
    ospf_interval: node['opennms']['enlinkd']['ospf_interval'],
    ospf_priority: node['opennms']['enlinkd']['ospf_priority'],
    isis: node['opennms']['enlinkd']['isis'],
    isis_interval: node['opennms']['enlinkd']['isis_interval'],
    isis_priority: node['opennms']['enlinkd']['isis_priority'],
    topology_interval: node['opennms']['enlinkd']['topology_interval'],
    bridge_topo_interval: node['opennms']['enlinkd']['bridge_topo_interval'],
    max_bft: node['opennms']['enlinkd']['max_bft'],
    disco_bridge_threads: node['opennms']['enlinkd']['disco_bridge_threads']
  )
  action node['opennms']['templates'] ? :create : :nothing
end

template "#{onms_home}/etc/eventd-configuration.xml" do
  cookbook node['opennms']['eventd']['cookbook']
  source 'eventd-configuration.xml.erb'
  mode '0664'
  owner node['opennms']['username']
  group node['opennms']['groupname']
  notifies :restart, 'service[opennms]'
  variables(
    tcp_address: node['opennms']['eventd']['tcp_address'],
    tcp_port: node['opennms']['eventd']['tcp_port'],
    udp_address: node['opennms']['eventd']['udp_address'],
    udp_port: node['opennms']['eventd']['udp_port'],
    receivers: node['opennms']['eventd']['receivers'],
    get_next_eventid: node['opennms']['eventd']['get_next_eventid'],
    sock_so_timeout_req: node['opennms']['eventd']['sock_so_timeout_req'],
    socket_so_timeout_period: node['opennms']['eventd']['socket_so_timeout_period']
  )
  action node['opennms']['templates'] ? :create : :nothing
end

template "#{onms_home}/etc/javamail-configuration.properties" do
  cookbook node['opennms']['javamail_props']['cookbook']
  source 'javamail-configuration.properties.erb'
  mode '0664'
  owner node['opennms']['username']
  group node['opennms']['groupname']
  variables(
    from_address: node['opennms']['javamail_props']['from_address'],
    mail_host: node['opennms']['javamail_props']['mail_host'],
    mailer: node['opennms']['javamail_props']['mailer'],
    transport: node['opennms']['javamail_props']['transport'],
    debug: node['opennms']['javamail_props']['debug'],
    smtpport: node['opennms']['javamail_props']['smtpport'],
    smtpssl: node['opennms']['javamail_props']['smtpssl'],
    quitwait: node['opennms']['javamail_props']['quitwait'],
    use_JMTA: node['opennms']['javamail_props']['use_JMTA'],
    authenticate: node['opennms']['javamail_props']['authenticate'],
    authenticate_user: node['opennms']['javamail_props']['authenticate_user'],
    authenticate_password: node['opennms']['javamail_props']['authenticate_password'],
    starttls: node['opennms']['javamail_props']['starttls'],
    message_content_type: node['opennms']['javamail_props']['message_content_type'],
    charset: node['opennms']['javamail_props']['charset']
  )
  action node['opennms']['templates'] ? :create : :nothing
end

template "#{onms_home}/etc/javamail-configuration.xml" do
  cookbook node['opennms']['javamail_config']['cookbook']
  source 'javamail-configuration.xml.erb'
  mode '0664'
  owner node['opennms']['username']
  group node['opennms']['groupname']
  notifies :restart, 'service[opennms]'
  variables(
    default_read_config_name: node['opennms']['javamail_config']['default_read_config_name'],
    default_send_config_name: node['opennms']['javamail_config']['default_send_config_name'],
    dr_attempt_interval: node['opennms']['javamail_config']['default_read']['attempt_interval'],
    dr_delete_all_mail: node['opennms']['javamail_config']['default_read']['delete_all_mail'],
    dr_mail_folder: node['opennms']['javamail_config']['default_read']['mail_folder'],
    dr_debug: node['opennms']['javamail_config']['default_read']['debug'],
    dr_properties: node['opennms']['javamail_config']['default_read']['properties'],
    dr_host: node['opennms']['javamail_config']['default_read']['host'],
    dr_port: node['opennms']['javamail_config']['default_read']['port'],
    dr_ssl_enable: node['opennms']['javamail_config']['default_read']['ssl_enable'],
    dr_start_tls: node['opennms']['javamail_config']['default_read']['start_tls'],
    dr_transport: node['opennms']['javamail_config']['default_read']['transport'],
    dr_user: node['opennms']['javamail_config']['default_read']['user'],
    dr_password: node['opennms']['javamail_config']['default_read']['password'],
    ds_attempt_interval: node['opennms']['javamail_config']['default_send']['attempt_interval'],
    ds_use_authentication: node['opennms']['javamail_config']['default_send']['use_authentication'],
    ds_use_jmta: node['opennms']['javamail_config']['default_send']['use_jmta'],
    ds_debug: node['opennms']['javamail_config']['default_send']['debug'],
    ds_host: node['opennms']['javamail_config']['default_send']['host'],
    ds_port: node['opennms']['javamail_config']['default_send']['port'],
    ds_char_set: node['opennms']['javamail_config']['default_send']['char_set'],
    ds_mailer: node['opennms']['javamail_config']['default_send']['mailer'],
    ds_content_type: node['opennms']['javamail_config']['default_send']['content_type'],
    ds_encoding: node['opennms']['javamail_config']['default_send']['encoding'],
    ds_quit_wait: node['opennms']['javamail_config']['default_send']['quit_wait'],
    ds_ssl_enable: node['opennms']['javamail_config']['default_send']['ssl_enable'],
    ds_start_tls: node['opennms']['javamail_config']['default_send']['start_tls'],
    ds_transport: node['opennms']['javamail_config']['default_send']['transport'],
    ds_to: node['opennms']['javamail_config']['default_send']['to'],
    ds_from: node['opennms']['javamail_config']['default_send']['from'],
    ds_subject: node['opennms']['javamail_config']['default_send']['subject'],
    ds_body: node['opennms']['javamail_config']['default_send']['body'],
    ds_user: node['opennms']['javamail_config']['default_send']['user'],
    ds_password: node['opennms']['javamail_config']['default_send']['password']
  )
  action node['opennms']['templates'] ? :create : :nothing
end

template "#{onms_home}/etc/jcifs.properties" do
  cookbook node['opennms']['jcifs']['cookbook']
  source 'jcifs.properties.erb'
  mode '0664'
  owner node['opennms']['username']
  group node['opennms']['groupname']
  notifies :restart, 'service[opennms]'
  variables(
    loglevel: node['opennms']['jcifs']['loglevel'],
    wins: node['opennms']['jcifs']['wins'],
    lmhosts: node['opennms']['jcifs']['lmhosts'],
    resolve_order: node['opennms']['jcifs']['resolve_order'],
    hostname: node['opennms']['jcifs']['hostname'],
    retry_count: node['opennms']['jcifs']['retry_count'],
    username: node['opennms']['jcifs']['username'],
    password: node['opennms']['jcifs']['password'],
    client_laddr: node['opennms']['jcifs']['client_laddr']
  )
  action node['opennms']['templates'] ? :create : :nothing
end

template "#{onms_home}/etc/jms-northbounder-configuration.xml" do
  source 'jms-northbounder-configuration.xml.erb'
  cookbook node['opennms']['jms_nbi']['cookbook']
  owner node['opennms']['username']
  group node['opennms']['groupname']
  variables(
    enabled: node['opennms']['jms_nbi']['enabled'],
    nagles_delay: node['opennms']['jms_nbi']['nagles_delay'],
    batch_size: node['opennms']['jms_nbi']['batch_size'],
    queue_size: node['opennms']['jms_nbi']['queue_size'],
    message_format: node['opennms']['jms_nbi']['message_format'],
    jms_destination: node['opennms']['jms_nbi']['jms_destination'],
    send_as_object_message: node['opennms']['jms_nbi']['send_as_object_message'],
    first_occurrence_only: node['opennms']['jms_nbi']['first_occurrence_only']
  )
  notifies :restart, 'service[opennms]'
  only_if { node['opennms']['plugin']['addl'].include?('opennms-plugin-northbounder-jms') }
  action node['opennms']['templates'] ? :create : :nothing
end

template "#{onms_home}/etc/microblog-configuration.xml" do
  cookbook node['opennms']['microblog']['cookbook']
  source 'microblog-configuration.xml.erb'
  mode '0664'
  owner node['opennms']['username']
  group node['opennms']['groupname']
  notifies :restart, 'service[opennms]'
  variables(
    default_profile: node['opennms']['microblog']['default_profile']
  )
  action node['opennms']['templates'] ? :create : :nothing
end

template "#{onms_home}/etc/modemConfig.properties" do
  cookbook node['opennms']['modem']['cookbook']
  source 'modemConfig.properties.erb'
  mode '0664'
  owner node['opennms']['username']
  group node['opennms']['groupname']
  notifies :restart, 'service[opennms]'
  variables(
    modem: node['opennms']['modem']['model'],
    custom_modem: node['opennms']['custom_modem']
  )
  action node['opennms']['templates'] ? :create : :nothing
end

template "#{onms_home}/etc/reportd-configuration.xml" do
  cookbook node['opennms']['reportd']['cookbook']
  source 'reportd-configuration.xml.erb'
  mode '0664'
  owner node['opennms']['username']
  group node['opennms']['groupname']
  notifies :restart, 'service[opennms]'
  variables(
    storage_location: node['opennms']['reportd']['storage_location'],
    persist_reports: node['opennms']['reportd']['persist_reports']
  )
  action node['opennms']['templates'] ? :create : :nothing
end

template "#{onms_home}/etc/response-adhoc-graph.properties" do
  cookbook node['opennms']['response_adhoc_graph']['cookbook']
  source 'response-adhoc-graph.properties.erb'
  mode '0664'
  owner node['opennms']['username']
  group node['opennms']['groupname']
  variables(
    command_prefix: node['opennms']['response_adhoc_graph']['command_prefix']
  )
  action node['opennms']['templates'] ? :create : :nothing
end

template "#{onms_home}/etc/rtc-configuration.xml" do
  cookbook node['opennms']['rtc']['cookbook']
  source 'rtc-configuration.xml.erb'
  mode '0664'
  owner node['opennms']['username']
  group node['opennms']['groupname']
  notifies :restart, 'service[opennms]'
  variables(
    updaters: node['opennms']['rtc']['updaters'],
    senders: node['opennms']['rtc']['senders'],
    rolling_window: node['opennms']['rtc']['rolling_window'],
    max_events_before_resend: node['opennms']['rtc']['max_events_before_resend'],
    low_threshold_interval: node['opennms']['rtc']['low_threshold_interval'],
    high_threshold_interval: node['opennms']['rtc']['high_threshold_interval'],
    user_refresh_interval: node['opennms']['rtc']['user_refresh_interval'],
    errors_before_url_unsubscribe: node['opennms']['rtc']['errors_before_url_unsubscribe']
  )
  action node['opennms']['templates'] ? :create : :nothing
end

template "#{onms_home}/etc/site-status-views.xml" do
  cookbook node['opennms']['site_status_views']['cookbook']
  source 'site-status-views.xml.erb'
  mode '0664'
  owner node['opennms']['username']
  group node['opennms']['groupname']
  variables(
    default_view: node['opennms']['site_status_views']['default_view']
  )
  action node['opennms']['templates'] ? :create : :nothing
end

template "#{onms_home}/etc/snmp-adhoc-graph.properties" do
  cookbook node['opennms']['snmp_adhoc_graph']['cookbook']
  source 'snmp-adhoc-graph.properties.erb'
  mode '0664'
  owner node['opennms']['username']
  group node['opennms']['groupname']
  variables(
    image_format: node['opennms']['snmp_adhoc_graph']['image_format'],
    command_prefix: node['opennms']['snmp_adhoc_graph']['command_prefix']
  )
  action node['opennms']['templates'] ? :create : :nothing
end

template "#{onms_home}/etc/snmp-interface-poller-configuration.xml" do
  cookbook node['opennms']['snmp_iface_poller']['cookbook']
  source 'snmp-interface-poller-configuration.xml.erb'
  mode '0664'
  owner node['opennms']['username']
  group node['opennms']['groupname']
  notifies :restart, 'service[opennms]'
  variables(
    threads: node['opennms']['snmp_iface_poller']['threads'],
    service: node['opennms']['snmp_iface_poller']['service'],
    node_outage: node['opennms']['snmp_iface_poller']['node_outage'],
    example1: node['opennms']['snmp_iface_poller']['example1'],
    upvalues: node['opennms']['snmp_iface_poller']['upvalues'],
    downvalues: node['opennms']['snmp_iface_poller']['downvalues']
  )
  action node['opennms']['templates'] ? :create : :nothing
end

template "#{onms_home}/etc/syslog-northbounder-configuration.xml" do
  cookbook node['opennms']['syslog_north']['cookbook']
  source 'syslog-northbounder-configuration.xml.erb'
  mode '0664'
  owner node['opennms']['username']
  group node['opennms']['groupname']
  notifies :restart, 'service[opennms]'
  variables(
    use_defaults: node['opennms']['syslog_north']['use_defaults'],
    enabled: node['opennms']['syslog_north']['enabled'],
    nagles_delay: node['opennms']['syslog_north']['nagles_delay'],
    batch_size: node['opennms']['syslog_north']['batch_size'],
    queue_size: node['opennms']['syslog_north']['queue_size'],
    message_format: node['opennms']['syslog_north']['message_format'],
    destination: node['opennms']['syslog_north']['destination'],
    uei: node['opennms']['syslog_north']['uei']
  )
  action node['opennms']['templates'] ? :create : :nothing
end

template "#{onms_home}/etc/translator-configuration.xml" do
  cookbook node['opennms']['translator']['cookbook']
  source 'translator-configuration.xml.erb'
  mode '0664'
  owner node['opennms']['username']
  group node['opennms']['groupname']
  variables(
    snmp_link_down: node['opennms']['translator']['snmp_link_down'],
    snmp_link_up: node['opennms']['translator']['snmp_link_up'],
    hyperic: node['opennms']['translator']['hyperic'],
    cisco_config_man: node['opennms']['translator']['cisco_config_man'],
    juniper_cfg_change: node['opennms']['translator']['juniper_cfg_change'],
    telemetry_clock_skew_detected: node['opennms']['translator']['telemetry_clock_skew_detected'],
    # Should be a array of hashes where each hash has a key 'uei' that has a hash value and key `'mappings'` (array of hashes each with key `'assignments'` (array of hashes that each contain keys `'name'` (string), `'type'` (string), `'default'` (string, optional), `'value'` (a hash that contains keys `'type'` (string), `'matches'` (string, optional), `'result'` (string), `'values'` (array of hashes that each contain keys `'type'` (string), `'matches'` (string, optional), `'result'` (string)))))
    addl_specs: node['opennms']['translator']['addl_specs']
  )
  action node['opennms']['templates'] ? :create : :nothing
end

template "#{onms_home}/etc/trapd-configuration.xml" do
  cookbook node['opennms']['trapd']['cookbook']
  source 'trapd-configuration.xml.erb'
  mode '0664'
  owner node['opennms']['username']
  group node['opennms']['groupname']
  notifies :restart, 'service[opennms]'
  variables(
    port: node['opennms']['trapd']['port'],
    new_suspect: node['opennms']['trapd']['new_suspect']
  )
  action node['opennms']['templates'] ? :create : :nothing
end

template "#{onms_home}/etc/vacuumd-configuration.xml" do
  cookbook node['opennms']['vacuumd']['cookbook']
  source 'vacuumd-configuration.xml.erb'
  mode '0664'
  owner node['opennms']['username']
  group node['opennms']['groupname']
  variables(
    period: node['opennms']['vacuumd']['period'],
    statement: node['opennms']['vacuumd']['statement'],
    automations: node['opennms']['vacuumd']['automations'],
    triggers: node['opennms']['vacuumd']['triggers'],
    actions: node['opennms']['vacuumd']['actions'],
    auto_events: node['opennms']['vacuumd']['auto_events'],
    action_events: node['opennms']['vacuumd']['action_events']
  )
  action node['opennms']['templates'] ? :create : :nothing
end

template "#{onms_home}/etc/vmware-cim-datacollection-config.xml" do
  cookbook node['opennms']['vmware_cim']['cookbook']
  source 'vmware-cim-datacollection-config.xml.erb'
  mode '0664'
  owner node['opennms']['username']
  group node['opennms']['groupname']
  notifies :restart, 'service[opennms]'
  variables(
    rrd_repository: node['opennms']['vmware_cim']['rrd_repository'],
    default_esx_hostsystem: node['opennms']['vmware_cim']['default_esx_hostsystem']
  )
  action node['opennms']['templates'] ? :create : :nothing
end

template "#{onms_home}/etc/vmware-datacollection-config.xml" do
  cookbook node['opennms']['vmware']['cookbook']
  source 'vmware-datacollection-config.xml.erb'
  mode '0664'
  owner node['opennms']['username']
  group node['opennms']['groupname']
  notifies :restart, 'service[opennms]'
  variables(
    rrd_repository: node['opennms']['vmware']['rrd_repository'],
    default_hostsystem3: node['opennms']['vmware']['default_hostsystem3'],
    default_vm3: node['opennms']['vmware']['default_vm3'],
    default_hostsystem4: node['opennms']['vmware']['default_hostsystem4'],
    default_vm4: node['opennms']['vmware']['default_vm4'],
    default_hostsystem5: node['opennms']['vmware']['default_hostsystem5'],
    default_vm5: node['opennms']['vmware']['default_vm5']
  )
  action node['opennms']['templates'] ? :create : :nothing
end

template "#{onms_home}/etc/xmpp-configuration.properties" do
  cookbook node['opennms']['xmpp']['cookbook']
  source 'xmpp-configuration.properties.erb'
  mode '0664'
  owner node['opennms']['username']
  group node['opennms']['groupname']
  notifies :restart, 'service[opennms]'
  variables(
    server: node['opennms']['xmpp']['server'],
    service_name: node['opennms']['xmpp']['service_name'],
    port: node['opennms']['xmpp']['port'],
    tls: node['opennms']['xmpp']['tls'],
    sasl: node['opennms']['xmpp']['sasl'],
    self_signed_certs: node['opennms']['xmpp']['self_signed_certs'],
    truststore_password: node['opennms']['xmpp']['truststore_password'],
    debug: node['opennms']['xmpp']['debug'],
    user: node['opennms']['xmpp']['user'],
    pass: node['opennms']['xmpp']['pass']
  )
  action node['opennms']['templates'] ? :create : :nothing
end

if node['opennms']['telemetryd']['managed']
  include_recipe 'opennms::telemetryd'
end

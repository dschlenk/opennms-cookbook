onms_home = '/opt/opennms'
# change default yum_timeout to 1200 because opennms packages are slow sometimes.
default['yum_timeout'] = 1200
default['opennms']['username'] = 'opennms'
default['opennms']['groupname'] = 'opennms'
# yum repo stuff
default['yum']['opennms']['key_url']                      = 'http://yum.opennms.org/OPENNMS-GPG-KEY'
default['yum']['opennms-stable-common']['baseurl']        = 'http://yum.opennms.org/stable/common'
default['yum']['opennms-stable-common']['failovermethod'] = 'roundrobin'
default['yum']['opennms-stable-rhel9']['baseurl']         = 'http://yum.opennms.org/stable/rhel9'
default['yum']['opennms-stable-rhel9']['failovermethod']  = 'roundrobin'
default['yum']['opennms-obsolete-common']['baseurl']        = 'http://yum.opennms.org/obsolete/common'
default['yum']['opennms-obsolete-common']['failovermethod'] = 'roundrobin'
default['yum']['opennms-obsolete-rhel9']['baseurl']         = 'http://yum.opennms.org/obsolete/rhel9'
default['yum']['opennms-obsolete-rhel9']['failovermethod']  = 'roundrobin'
default['yum']['opennms-snapshot-common']['baseurl']        = 'http://yum.opennms.org/snapshot/common'
default['yum']['opennms-snapshot-common']['failovermethod'] = 'roundrobin'
default['yum']['opennms-snapshot-rhel9']['baseurl']         = 'http://yum.opennms.org/snapshot/rhel9'
default['yum']['opennms-snapshot-rhel9']['failovermethod']  = 'roundrobin'
default['yum']['opennms-oldstable-common']['baseurl']        = 'http://yum.opennms.org/oldstable/common'
default['yum']['opennms-oldstable-common']['failovermethod'] = 'roundrobin'
default['yum']['opennms-oldstable-rhel9']['baseurl']         = 'http://yum.opennms.org/oldstable/rhel9'
default['yum']['opennms-oldstable-rhel9']['failovermethod']  = 'roundrobin'
default['opennms']['yum_gpg_keys'] = [
  'https://yum.opennms.org/OPENNMS-GPG-KEY',
]
# set to -Q to mimic OOTB quick start behavior on RHEL7+ (but you should not do this if using any of the opennms resources)
default['opennms']['start_opts'] = ''
# set to '' if you want to re-enable OOTB behavior (but you should not do this if using any of the opennms resources)
default['opennms']['timeout_start_sec'] = '10min'
default['opennms']['version'] = '33.1.4-1'
default['java']['version'] = '17'
default['opennms']['jre_path'] = nil
default['opennms']['allow_downgrade'] = false
default['opennms']['stable'] = true
# whether or not to attempt to automatically upgrade opennms
default['opennms']['upgrade'] = false
default['opennms']['upgrade_dirs'] = [
  'etc',
  'etc/datacollection',
  'etc/events',
  'etc/drools-engine.d/ncs',
  'etc/snmp-graph.properties.d',
  'jetty-webapps/opennms',
  'jetty-webapps/opennms/WEB-INF/',
  'jetty-webapps/opennms/WEB-INF/jsp/alarm',
  'jetty-webapps/opennms/WEB-INF/jsp/ncs',
  'jetty-webapps/opennms-remoting/WEB-INF',
]
# populate this with the names of additional packages you want installed.
# examples:
# * opennms-plugin-northbounder-jms
# * opennms-plugin-provisioning-snmp-asset
# * opennms-plugin-provisioning-snmp-hardware-inventory
# * opennms-plugin-provisioning-wsman-asset
default['opennms']['plugin']['addl'] = []
default['opennms']['addl_handlers'] = []
# change to true to generate a random password
default['opennms']['secure_admin'] = false
default['opennms']['conf']['home'] = onms_home
# opennms.conf
default['opennms']['conf']['env'] = {
  # required because we need opennms to fully start before resources will work
  'START_TIMEOUT' => 30,
  # see $OPENNMS_HOME/etc/examples/opennms.conf for more options, like:
  # 'JAVA_HEAP_SIZE' => 4096,
  # 'MAXIMUM_FILE_DESCRIPTORS' => 204800,
  # 'ADDITIONAL_MANAGER_OPTIONS' => '${ADDITIONAL_MANAGER_OPTIONS} -XX:+UseStringDeduplication',
}
# TEMPLATES

# whether or not to use all templates or just base.
# Once upon a time there were two different recipes
# for installation (default and notemplates) but now
# the latter just sets this attribute to false.
default['opennms']['templates'] = true
# default cookbook for templates
default['opennms']['default_template_cookbook'] = 'opennms'
default['opennms']['services']['cookbook']                 = node['opennms']['default_template_cookbook']
default['opennms']['db_reports']['avail']['cookbook']      = node['opennms']['default_template_cookbook']
default['opennms']['chart']['cookbook']                    = node['opennms']['default_template_cookbook']
default['opennms']['enlinkd']['cookbook']                  = node['opennms']['default_template_cookbook']
default['opennms']['eventd']['cookbook']                   = node['opennms']['default_template_cookbook']
default['opennms']['javamail_props']['cookbook']           = node['opennms']['default_template_cookbook']
default['opennms']['javamail_config']['cookbook']          = node['opennms']['default_template_cookbook']
default['opennms']['jcifs']['cookbook']                    = node['opennms']['default_template_cookbook']
default['opennms']['log4j2']['cookbook']                   = node['opennms']['default_template_cookbook']
default['opennms']['microblog']['cookbook']                = node['opennms']['default_template_cookbook']
default['opennms']['modem']['cookbook']                    = node['opennms']['default_template_cookbook']
default['opennms']['nsclient_datacollection']['cookbook']  = node['opennms']['default_template_cookbook']
default['opennms']['reportd']['cookbook']                  = node['opennms']['default_template_cookbook']
default['opennms']['response_adhoc_graph']['cookbook']     = node['opennms']['default_template_cookbook']
default['opennms']['rtc']['cookbook']                      = node['opennms']['default_template_cookbook']
default['opennms']['site_status_views']['cookbook']        = node['opennms']['default_template_cookbook']
default['opennms']['snmp_adhoc_graph']['cookbook']         = node['opennms']['default_template_cookbook']
default['opennms']['snmp_iface_poller']['cookbook']        = node['opennms']['default_template_cookbook']
default['opennms']['syslog_north']['cookbook']             = node['opennms']['default_template_cookbook']
default['opennms']['translator']['cookbook']               = node['opennms']['default_template_cookbook']
default['opennms']['vacuumd']['cookbook']                  = node['opennms']['default_template_cookbook']
default['opennms']['web_console_view']['cookbook']         = node['opennms']['default_template_cookbook']
default['opennms']['vmware_cim']['cookbook']               = node['opennms']['default_template_cookbook']
default['opennms']['vmware']['cookbook']                   = node['opennms']['default_template_cookbook']
default['opennms']['xmpp']['cookbook']                     = node['opennms']['default_template_cookbook']
# RRD locations
# defaults
default['opennms']['default_rrd_repository'] = "#{onms_home}/share/rrd/snmp/"
def_rrd_repo = "#{onms_home}/share/rrd/snmp/"
default['opennms']['default_response_rrd_repository'] = "#{onms_home}/share/rrd/response"
def_rrd_resp_repo = "#{onms_home}/share/rrd/response"
# specifics
default['opennms']['poller']['example1']['icmp']['rrd_repository']            = def_rrd_resp_repo
default['opennms']['poller']['example1']['dns']['rrd_repository']             = def_rrd_resp_repo
default['opennms']['poller']['example1']['smtp']['rrd_repository']            = def_rrd_resp_repo
default['opennms']['poller']['example1']['http']['rrd_repository']            = def_rrd_resp_repo
default['opennms']['poller']['example1']['http_8080']['rrd_repository']       = def_rrd_resp_repo
default['opennms']['poller']['example1']['http_8000']['rrd_repository']       = def_rrd_resp_repo
default['opennms']['poller']['example1']['https']['rrd_repository']           = def_rrd_resp_repo
default['opennms']['poller']['example1']['hyperichq']['rrd_repository']       = def_rrd_resp_repo
default['opennms']['poller']['example1']['ssh']['rrd_repository']             = def_rrd_resp_repo
default['opennms']['poller']['example1']['pop3']['rrd_repository']            = def_rrd_resp_repo
default['opennms']['poller']['example1']['nrpe']['rrd_repository']            = def_rrd_resp_repo
default['opennms']['poller']['example1']['nrpe_nossl']['rrd_repository']      = def_rrd_resp_repo
default['opennms']['poller']['example1']['opennms_jvm']['rrd_repository']     = def_rrd_resp_repo
default['opennms']['poller']['strafer']['strafeping']['rrd_repository']       = def_rrd_resp_repo
default['opennms']['jdbc_dc']['rrd_repository']                               = def_rrd_repo
default['opennms']['jmx_dc']['rrd_repository']                                = def_rrd_repo
default['opennms']['wsman_dc']['rrd_repository']                              = def_rrd_repo
default['opennms']['nsclient_datacollection']['rrd_repository']               = def_rrd_repo
default['opennms']['thresholds']['mib2']['rrd_repository']                    = def_rrd_repo
default['opennms']['thresholds']['hrstorage']['rrd_repository']               = def_rrd_repo
default['opennms']['thresholds']['cisco']['rrd_repository']                   = def_rrd_repo
default['opennms']['thresholds']['netsnmp']['rrd_repository']                 = def_rrd_repo
default['opennms']['thresholds']['netsnmp_memory_linux']['rrd_repository']    = def_rrd_repo
default['opennms']['thresholds']['netsnmp_memory_nonlinux']['rrd_repository'] = def_rrd_repo
default['opennms']['thresholds']['coffee']['rrd_repository']                  = def_rrd_repo
default['opennms']['vmware_cim']['rrd_repository']                            = def_rrd_repo
default['opennms']['vmware']['rrd_repository']                                = def_rrd_repo
default['opennms']['wmi']['rrd_repository']                                   = def_rrd_repo
default['opennms']['xml']['rrd_repository']                                   = def_rrd_repo

# users.xml
default['opennms']['users']['admin']['name']          = 'Administrator'
default['opennms']['users']['admin']['user_comments'] = 'Default administrator, do not delete'
# if you want to change the admin password to something specific, you must provide the node with a vault item that contains JSON like:
# {
#     "password": "thePassword"
# }
default['opennms']['users']['admin']['vault'] = Chef::Config[:node_name]
# must contain a value named `password`.
default['opennms']['users']['admin']['vault_item'] = 'opennms_admin_password'

# daemons
default['opennms']['services']['dhcpd']               = false
default['opennms']['services']['snmp_poller']         = false
default['opennms']['services']['linkd']               = false
default['opennms']['services']['correlator']          = false
default['opennms']['services']['tl1d']                = false
default['opennms']['services']['syslogd']             = false
default['opennms']['services']['xmlrpcd']             = false
default['opennms']['services']['asterisk_gw']         = false
default['opennms']['services']['apm']                 = false
default['opennms']['services']['telemetryd']          = true
default['opennms']['services']['perspective_poller']  = true
default['opennms']['services']['bsmd']                = true
default['opennms']['services']['discovery']           = true
default['opennms']['services']['ticketer']            = true

# opennms.properties
default['opennms']['properties']['files'] = {
  #  Use to define properties overrides in `$OPENNMS_HOME/etc/opennms.properties.d`.
  #  For example, to override property `org.opennms.features.scv.jceks.key` in a file named `$OPENNMS_HOME/etc/opennms.properties.d/scv.properties`, do:
  #  'scv' => {
  #    'org.opennms.features.scv.jceks.key' => 'pw'
  #  }
}
# if you change one of the following via the mechanism above, you also need to update it here:
default['opennms']['properties']['dc']['rrd_base_dir']              = "#{onms_home}/share/rrd/snmp"
default['opennms']['properties']['jetty']['port']                   = 8980
# we no longer manage the main opennms.proeprties file; these legacy attributes no longer used
# default['opennms']['properties']['misc']['bin_dir']                 = "#{onms_home}/bin"
# default['opennms']['properties']['reporting']['template_dir']       = "#{onms_home}/etc"
# default['opennms']['properties']['reporting']['report_dir']         = "#{onms_home}/share/reports"
# default['opennms']['properties']['reporting']['report_logo']        = "#{onms_home}/webapps/images/logo.gif"
# default['opennms']['properties']['reporting']['scheduler_enabled']  = true
# # ICMP
# default['opennms']['properties']['icmp']['pinger_class'] = nil # "org.opennms.netmgt.icmp.jni6.Jni6Pinger"
# default['opennms']['properties']['icmp']['require_v4']   = nil
# default['opennms']['properties']['icmp']['require_v6']   = nil
# # SNMP
# default['opennms']['properties']['snmp']['strategy_class']             = nil
# default['opennms']['properties']['snmp']['smisyntaxes']                = 'opennms-snmp4j-smisyntaxes.properties'
# default['opennms']['properties']['snmp']['forward_runtime_exceptions'] = false
# default['opennms']['properties']['snmp']['log_factory']                = 'org.snmp4j.log.Log4jLogFactory'
# default['opennms']['properties']['snmp']['allow_64bit_ipaddress']      = true
# default['opennms']['properties']['snmp']['no_getbulk']                 = false
# default['opennms']['properties']['snmp']['allow_snmpv2_in_v1']         = false
# # Data collection
# default['opennms']['properties']['dc']['store_by_group']          = false
# default['opennms']['properties']['dc']['store_by_foreign_source'] = false
# default['opennms']['properties']['dc']['rrd_dc_dir']              = '/snmp/'
# default['opennms']['properties']['dc']['rrd_binary']              = '/usr/bin/rrdtool'
# default['opennms']['properties']['dc']['decimal_format']          = nil
# default['opennms']['properties']['dc']['reload_check_interval']   = nil
# default['opennms']['properties']['dc']['instrumentation_class']   = nil
# default['opennms']['properties']['dc']['enable_check_file_mod']   = nil
# default['opennms']['properties']['dc']['cache_timeout']           = nil
# default['opennms']['properties']['dc']['force_rescan']            = nil
# default['opennms']['properties']['dc']['instance_limiting']       = nil
# # Alarmd
# default['opennms']['properties']['alarmd']['new_if_cleared_alarm_exists'] = nil
# default['opennms']['properties']['alarmd']['legacy_alarm_state']          = nil
# # Remote
# default['opennms']['properties']['remote']['exclude_service_monitors'] = 'DHCP,NSClient,RadiusAuth,XMP'
# default['opennms']['properties']['remote']['min_config_reload_int']    = nil
# default['opennms']['properties']['remote']['pb_disconnect_timeout']    = nil
# default['opennms']['properties']['remote']['pb_server_port']           = nil
# default['opennms']['properties']['remote']['pb_registry_port']         = nil
# # Ticketing
# default['opennms']['properties']['ticket']['servicelayer']  = 'org.opennms.netmgt.ticketd.DefaultTicketerServiceLayer'
# default['opennms']['properties']['ticket']['plugin']        = 'org.opennms.netmgt.ticketd.NullTicketerPlugin'
# default['opennms']['properties']['ticket']['enabled']       = nil
# default['opennms']['properties']['ticket']['link_template'] = nil
# default['opennms']['properties']['ticket']['skip_create_when_cleared'] = true
# default['opennms']['properties']['ticket']['skip_close_when_not_cleared'] = true
# # Misc
# default['opennms']['properties']['misc']['layout_applications_vertically'] = false
# default['opennms']['properties']['misc']['webapp_logs_dir']                = '${install.logs.dir}'
# default['opennms']['properties']['misc']['headless']                       = true
# default['opennms']['properties']['misc']['find_by_service_type_query']     = nil
# default['opennms']['properties']['misc']['load_snmp_data_on_init']         = nil
# default['opennms']['properties']['misc']['allow_html_fields']              = nil
# default['opennms']['properties']['misc']['allow_unsalted']                 = nil
# # Reporting
# default['opennms']['properties']['reporting']['jasper_version'] = '6.3.0'
# default['opennms']['properties']['reporting']['ksc_graphs_per_line'] = 1
# # Eventd IPC
# default['opennms']['properties']['eventd']['proxy_host']     = nil
# default['opennms']['properties']['eventd']['proxy_port']     = nil
# default['opennms']['properties']['eventd']['proxy_timeout']  = nil
# # RANCID
# default['opennms']['properties']['rancid']['enabled']              = nil
# default['opennms']['properties']['rancid']['only_rancid_adapter']  = nil
# # RTC IPC
# default['opennms']['properties']['rtc']['baseurl']   = 'http://localhost:8980/opennms/rtc/post'
# default['opennms']['properties']['rtc']['username']  = 'rtc'
# default['opennms']['properties']['rtc']['password']  = 'rtc'
# default['opennms']['properties']['rtc']['pwhash']    = 'sHMy+HycWKGJC/uUMF0IGlXUXP1KhcqD0GEchFlvYTw40jT9r+zMxOb3F+phWNzX'
# # MAP IPC
# default['opennms']['properties']['map']['baseurl']   = 'http://localhost:8980/opennms/map/post'
# default['opennms']['properties']['map']['username']  = 'map'
# default['opennms']['properties']['map']['password']  = 'map'
# # JETTY
# default['opennms']['properties']['jetty']['ajp']                    = nil
# default['opennms']['properties']['jetty']['host']                   = nil
# default['opennms']['properties']['jetty']['req_logging']            = nil
# default['opennms']['properties']['jetty']['max_form_content_size']  = nil
# default['opennms']['properties']['jetty']['request_header_size']    = nil
# default['opennms']['properties']['jetty']['max_form_keys']          = 2000
# default['opennms']['properties']['jetty']['https_port']             = nil
# default['opennms']['properties']['jetty']['https_host']             = nil
# default['opennms']['properties']['jetty']['keystore']               = nil
# default['opennms']['properties']['jetty']['ks_password']            = nil
# default['opennms']['properties']['jetty']['key_password']           = nil
# default['opennms']['properties']['jetty']['cert_alias']             = nil
# default['opennms']['properties']['jetty']['exclude_cipher_suites']  = nil
# default['opennms']['properties']['jetty']['https_baseurl']          = nil
# default['opennms']['properties']['jetty']['datetimeformat']         = nil
# default['opennms']['properties']['jetty']['show_stacktrace']        = nil
# default['opennms']['properties']['jetty']['topology_entity_cache_duration'] = nil
# # JMS NB
# default['opennms']['properties']['jms_nbi']['broker_url'] = nil
# default['opennms']['properties']['jms_nbi']['activemq_username'] = nil
# default['opennms']['properties']['jms_nbi']['activemq_password'] = nil
# # UI
# default['opennms']['properties']['ui']['acls']                        = nil
# default['opennms']['properties']['ui']['ack']                         = false
# default['opennms']['properties']['ui']['show_count']                  = false
# default['opennms']['properties']['ui']['show_outage_nodes']           = nil
# default['opennms']['properties']['ui']['show_problem_nodes']          = nil
# default['opennms']['properties']['ui']['show_situations']             = nil
# default['opennms']['properties']['ui']['outage_node_count']           = nil
# default['opennms']['properties']['ui']['problem_node_count']          = nil
# default['opennms']['properties']['ui']['situations_count']            = nil
# default['opennms']['properties']['ui']['show_node_status_bar']        = nil
# default['opennms']['properties']['ui']['disable_login_success_event'] = nil
# default['opennms']['properties']['ui']['max_interface_count']         = nil
# default['opennms']['properties']['ui']['center_url']                  = nil
# # Asterisk AGI
# default['opennms']['properties']['asterisk']['listen_address'] = nil
# default['opennms']['properties']['asterisk']['listen_port']    = nil
# default['opennms']['properties']['asterisk']['max_pool_size']  = nil
# # Provisioning
# default['opennms']['properties']['provisioning']['dns_server']                = '127.0.0.1'
# default['opennms']['properties']['provisioning']['dns_level']                 = nil
# default['opennms']['properties']['provisioning']['reverse_dns_level']         = nil
# default['opennms']['properties']['provisioning']['max_concurrent_xtn']        = nil
# default['opennms']['properties']['provisioning']['enable_discovery']          = nil
# default['opennms']['properties']['provisioning']['enable_deletions']          = nil
# default['opennms']['properties']['provisioning']['schedule_existing_rescans'] = nil
# default['opennms']['properties']['provisioning']['schedule_updated_rescans']  = nil
# # SMS Gateway
# default['opennms']['properties']['sms']['serial_ports']  = '/dev/ttyACM0:/dev/ttyACM1:/dev/ttyACM2:/dev/ttyACM3:/dev/ttyACM4:/dev/ttyACM5'
# default['opennms']['properties']['sms']['polling']       = true
# # Mapping / Geocoding
# default['opennms']['properties']['geo']['map_type']       = 'OpenLayers'
# default['opennms']['properties']['geo']['api_key']        = ''
# default['opennms']['properties']['geo']['geocoder_class'] = nil # "org.opennms.features.poller.remote.gwt.server.geocoding.NullGeocoder"
# default['opennms']['properties']['geo']['rate']           = 10
# default['opennms']['properties']['geo']['referrer']       = 'http://localhost/'
# default['opennms']['properties']['geo']['min_quality']    = 'ZIP'
# default['opennms']['properties']['geo']['email']          = ''
# default['opennms']['properties']['geo']['tile_url']       = nil # "http://otile1.mqcdn.com/tiles/1.0.0/osm/${z}/${x}/${y}.png"
# default['opennms']['properties']['time_series']['strategy'] = 'rrd' # newts
# default['opennms']['properties']['graph_engine'] = 'backshift' # auto, png, placeholder, backshift
# default['opennms']['properties']['graph_period'] = nil
# default['opennms']['properties']['newts']['hostname'] = 'localhost'
# default['opennms']['properties']['newts']['keyspace'] = 'newts'
# default['opennms']['properties']['newts']['port'] = 9042
# default['opennms']['properties']['newts']['username'] = 'cassandra'
# default['opennms']['properties']['newts']['password'] = 'cassandra'
# default['opennms']['properties']['newts']['read_consistency'] = 'ONE'
# default['opennms']['properties']['newts']['write_consistency'] = 'ANY'
# default['opennms']['properties']['newts']['max_batch_size'] = 16
# default['opennms']['properties']['newts']['ring_buffer_size'] = 8192
# default['opennms']['properties']['newts']['ttl'] = 31_540_000
# default['opennms']['properties']['newts']['resource_shard'] = 604_800
# default['opennms']['properties']['newts']['cache_strategy'] = 'org.opennms.netmgt.newts.support.GuavaSearchableResourceMetadataCache'
# default['opennms']['properties']['newts']['cache_max_entries'] = 8192
# default['opennms']['properties']['newts']['cache_redis_host'] = 'localhost'
# default['opennms']['properties']['newts']['cache_redis_port'] = 6379
# default['opennms']['properties']['newts']['nan_on_counter_wrap'] = true
# default['opennms']['properties']['newts']['cache_priming_disable'] = false
# default['opennms']['properties']['newts']['cache_priming_block_ms'] = 120000
# default['opennms']['properties']['statusbox']['elements'] = nil # defaults to 'business-services,nodes-by-alarms,nodes-by-outages' in 21
# default['opennms']['properties']['heatmap']['default_mode'] = 'alarms' # outages
# default['opennms']['properties']['heatmap']['default_heatmap'] = 'categories' # or 'foreignSources' or 'monitoredServices'
# default['opennms']['properties']['heatmap']['category_filter'] = '.*'
# default['opennms']['properties']['heatmap']['foreign_source_filter'] = '.*'
# default['opennms']['properties']['heatmap']['service_filter'] = '.*'
# default['opennms']['properties']['heatmap']['only_unacknowledged'] = false
# default['opennms']['properties']['grafana']['show'] = false
# default['opennms']['properties']['grafana']['hostname'] = 'localhost'
# default['opennms']['properties']['grafana']['port'] = 3000
# default['opennms']['properties']['grafana']['api_key'] = ''
# default['opennms']['properties']['grafana']['tag'] = ''
# default['opennms']['properties']['grafana']['protocol'] = 'http'
# default['opennms']['properties']['grafana']['connection_timeout'] = 500
# default['opennms']['properties']['grafana']['so_timeout'] = 500
# default['opennms']['properties']['grafana']['dashboard_limit'] = 0
# default['opennms']['properties']['grafana']['base_path'] = ''
# default['opennms']['properties']['vmware']['housekeeping_interval'] = nil
# default['opennms']['properties']['alarmlist']['sound_enable'] = false
# default['opennms']['properties']['alarmlist']['sound_status'] = 'off' # newalarm, newalarmcount
# default['opennms']['properties']['alarmlist']['unackflash'] = false
# default['opennms']['properties']['rest_aliases'] = '/rest,/api/v2'
# default['opennms']['properties']['maxFlowAgeSeconds'] = nil
# default['opennms']['properties']['ingressAndEgressRequired'] = false
# default['opennms']['properties']['search_info'] = nil

# database reports - availability
default['opennms']['db_reports']['avail']['cal']['logo']                    = "#{onms_home}/etc/reports/logo.png"
default['opennms']['db_reports']['avail']['classic']['logo']                = "#{onms_home}/etc/reports/logo.png"
default['opennms']['db_reports']['avail']['cal']['endDate']['interval']     = 'day'
default['opennms']['db_reports']['avail']['cal']['endDate']['count']        = 1
default['opennms']['db_reports']['avail']['cal']['endDate']['hours']        = 23
default['opennms']['db_reports']['avail']['cal']['endDate']['minutes']      = 59
default['opennms']['db_reports']['avail']['classic']['endDate']['interval'] = 'day'
default['opennms']['db_reports']['avail']['classic']['endDate']['count']    = 1
default['opennms']['db_reports']['avail']['classic']['endDate']['hours']    = 23
default['opennms']['db_reports']['avail']['classic']['endDate']['minutes']  = 59
# chart-configuration.xml
default['opennms']['chart']['severity_enable']  = true
default['opennms']['chart']['outages_enable']   = true
default['opennms']['chart']['inventory_enable'] = true
# collectd-configuration.xml
# if set, overrides value currently found in file
default['opennms']['collectd']['threads'] = nil
# discovery-configuration.xml
default['opennms']['discovery']['threads']          = 1
default['opennms']['discovery']['pps']              = 1
default['opennms']['discovery']['init_sleep_ms']    = 30_000
default['opennms']['discovery']['restart_sleep_ms'] = 86_400_000
default['opennms']['discovery']['retries']          = 1
default['opennms']['discovery']['timeout']          = 2000
default['opennms']['discovery']['foreign_source']   = nil
# enlinkd-configuration.xml
default['opennms']['enlinkd']['threads'] = 3
default['opennms']['enlinkd']['executor_queue_size'] = 100
default['opennms']['enlinkd']['executor_threads'] = 5
default['opennms']['enlinkd']['init_sleep_time'] = 60_000
default['opennms']['enlinkd']['cdp'] = true
default['opennms']['enlinkd']['cdp_interval'] = 86400000
default['opennms']['enlinkd']['cdp_priority'] = 1000
default['opennms']['enlinkd']['bridge'] = true
default['opennms']['enlinkd']['bridge_interval'] = 86400000
default['opennms']['enlinkd']['bridge_priority'] = 10000
default['opennms']['enlinkd']['lldp'] = true
default['opennms']['enlinkd']['lldp_interval'] = 86400000
default['opennms']['enlinkd']['lldp_priority'] = 2000
default['opennms']['enlinkd']['ospf'] = true
default['opennms']['enlinkd']['ospf_interval'] = 86400000
default['opennms']['enlinkd']['ospf_priority'] = 3000
default['opennms']['enlinkd']['isis'] = true
default['opennms']['enlinkd']['isis_interval'] = 86400000
default['opennms']['enlinkd']['isis_priority'] = 4000
default['opennms']['enlinkd']['topology_interval'] = 30000
default['opennms']['enlinkd']['bridge_topo_interval'] = 300000
default['opennms']['enlinkd']['max_bft'] = 100
default['opennms']['enlinkd']['disco_bridge_threads'] = 1
# eventd-configuration.xml
default['opennms']['eventd']['tcp_address']            = '127.0.0.1'
default['opennms']['eventd']['tcp_port']               = 5817
default['opennms']['eventd']['udp_address']            = '127.0.0.1'
default['opennms']['eventd']['udp_port']               = 5817
default['opennms']['eventd']['receivers']              = 5
default['opennms']['eventd']['get_next_eventid']       = "SELECT nextval('eventsNxtId')"
default['opennms']['eventd']['sock_so_timeout_req']    = true
default['opennms']['eventd']['socket_so_timeout_period'] = 3000
# javamail-configuration.properties
default['opennms']['javamail_props']['from_address']          = nil
default['opennms']['javamail_props']['mail_host']             = nil
default['opennms']['javamail_props']['mailer']                = nil
default['opennms']['javamail_props']['transport']             = nil
default['opennms']['javamail_props']['debug']                 = nil
default['opennms']['javamail_props']['smtpport']              = nil
default['opennms']['javamail_props']['smtpssl']               = nil
default['opennms']['javamail_props']['quitwait']              = nil
default['opennms']['javamail_props']['use_JMTA']              = nil
default['opennms']['javamail_props']['authenticate']          = nil
default['opennms']['javamail_props']['authenticate_user']     = nil
default['opennms']['javamail_props']['authenticate_password'] = nil
default['opennms']['javamail_props']['starttls']              = nil
default['opennms']['javamail_props']['message_content_type']  = nil
default['opennms']['javamail_props']['charset']               = nil
# javamail-configuration.xml
default['opennms']['javamail_config']['default_read_config_name'] = 'localhost'
default['opennms']['javamail_config']['default_send_config_name'] = 'localhost'
default['opennms']['javamail_config']['default_read']['attempt_interval'] = 1000
default['opennms']['javamail_config']['default_read']['delete_all_mail']  = false
default['opennms']['javamail_config']['default_read']['mail_folder']      = 'INBOX'
default['opennms']['javamail_config']['default_read']['debug']            = true
default['opennms']['javamail_config']['default_read']['properties']       = { 'mail.pop3.apop.enable' => false, 'mail.pop3.rsetbeforequit' => false }
default['opennms']['javamail_config']['default_read']['host']             = '127.0.0.1'
default['opennms']['javamail_config']['default_read']['port']             = 110
default['opennms']['javamail_config']['default_read']['ssl_enable']       = false
default['opennms']['javamail_config']['default_read']['start_tls']        = false
default['opennms']['javamail_config']['default_read']['transport']        = 'pop3'
default['opennms']['javamail_config']['default_read']['user']             = 'opennms'
default['opennms']['javamail_config']['default_read']['password']         = 'opennms'
default['opennms']['javamail_config']['default_send']['attempt_interval']   = 3000
default['opennms']['javamail_config']['default_send']['use_authentication'] = false
default['opennms']['javamail_config']['default_send']['use_jmta']           = true
default['opennms']['javamail_config']['default_send']['debug']              = true
default['opennms']['javamail_config']['default_send']['host']               = '127.0.0.1'
default['opennms']['javamail_config']['default_send']['port']               = 25
default['opennms']['javamail_config']['default_send']['char_set']           = 'us-ascii'
default['opennms']['javamail_config']['default_send']['mailer']             = 'smtpsend'
default['opennms']['javamail_config']['default_send']['content_type']       = 'text/plain'
default['opennms']['javamail_config']['default_send']['encoding']           = '7-bit'
default['opennms']['javamail_config']['default_send']['quit_wait']          = true
default['opennms']['javamail_config']['default_send']['ssl_enable']         = false
default['opennms']['javamail_config']['default_send']['start_tls']          = false
default['opennms']['javamail_config']['default_send']['transport']          = 'smtp'
default['opennms']['javamail_config']['default_send']['to']                 = 'root@localhost'
default['opennms']['javamail_config']['default_send']['from']               = 'root@[127.0.0.1]'
default['opennms']['javamail_config']['default_send']['subject']            = 'OpenNMS Test Message'
default['opennms']['javamail_config']['default_send']['body']               = 'This is an OpenNMS test message.'
default['opennms']['javamail_config']['default_send']['user']               = 'opennms'
default['opennms']['javamail_config']['default_send']['password']           = 'opennms'
# jcifs.properties
default['opennms']['jcifs']['loglevel']      = 1
default['opennms']['jcifs']['wins']          = nil
default['opennms']['jcifs']['lmhosts']       = nil
default['opennms']['jcifs']['resolve_order'] = nil
default['opennms']['jcifs']['hostname']      = nil
default['opennms']['jcifs']['retry_count']   = nil
default['opennms']['jcifs']['username']      = nil
default['opennms']['jcifs']['password']      = nil
default['opennms']['jcifs']['client_laddr']  = nil
# jms-northbounder-config.xml
default['opennms']['jms_nbi']['cookbook']               = 'opennms'
default['opennms']['jms_nbi']['enabled']                = false
default['opennms']['jms_nbi']['nagles_delay']           = 1000
default['opennms']['jms_nbi']['batch_size']             = 100
default['opennms']['jms_nbi']['queue_size']             = 300_000
default['opennms']['jms_nbi']['message_format']         = 'ALARM ID:${alarmId} NODE:${nodeLabel}; ${logMsg}'
default['opennms']['jms_nbi']['send_as_object_message'] = false
default['opennms']['jms_nbi']['first_occurrence_only'] = true
default['opennms']['jms_nbi']['jms_destination'] = 'SingleAlarmQueue'
# log4j2.xml
default['opennms']['log4j2']['default_route']['size'] = '100MB'
default['opennms']['log4j2']['default_route']['rollover'] = 4
default['opennms']['log4j2']['instrumentation']['size'] = '100MB'
default['opennms']['log4j2']['instrumentation']['rollover'] = 4
default['opennms']['log4j2']['size'] = '100MB'
default['opennms']['log4j2']['access_point_monitor'] = 'WARN'
default['opennms']['log4j2']['ackd'] = 'WARN'
default['opennms']['log4j2']['actiond'] = 'WARN'
default['opennms']['log4j2']['alarmd'] = 'WARN'
default['opennms']['log4j2']['asterisk_gateway'] = 'WARN'
default['opennms']['log4j2']['archiver'] = 'WARN'
default['opennms']['log4j2']['bsmd'] = 'WARN'
default['opennms']['log4j2']['capsd'] = 'WARN'
default['opennms']['log4j2']['collectd'] = 'WARN'
default['opennms']['log4j2']['correlator'] = 'WARN'
default['opennms']['log4j2']['dhcpd'] = 'WARN'
default['opennms']['log4j2']['discovery'] = 'WARN'
default['opennms']['log4j2']['eventd'] = 'WARN'
default['opennms']['log4j2']['event_translator'] = 'WARN'
default['opennms']['log4j2']['icmp'] = 'WARN'
default['opennms']['log4j2']['ipc'] = 'WARN'
default['opennms']['log4j2']['jetty_server'] = 'WARN'
default['opennms']['log4j2']['linkd'] = 'WARN'
default['opennms']['log4j2']['enlinkd'] = 'WARN'
default['opennms']['log4j2']['manager'] = 'DEBUG'
default['opennms']['log4j2']['map'] = 'WARN'
default['opennms']['log4j2']['minion'] = 'WARN'
default['opennms']['log4j2']['model_importer'] = 'WARN'
default['opennms']['log4j2']['notifd'] = 'WARN'
default['opennms']['log4j2']['oss_qosd'] = 'WARN'
default['opennms']['log4j2']['oss_qosdrx'] = 'WARN'
default['opennms']['log4j2']['passive'] = 'WARN'
default['opennms']['log4j2']['perspective_pollerd'] = 'WARN'
default['opennms']['log4j2']['poller'] = 'WARN'
default['opennms']['log4j2']['provisiond'] = 'WARN'
default['opennms']['log4j2']['queued'] = 'WARN'
default['opennms']['log4j2']['reportd'] = 'WARN'
default['opennms']['log4j2']['reports'] = 'WARN'
default['opennms']['log4j2']['rtc'] = 'WARN'
default['opennms']['log4j2']['syslogd'] = 'WARN'
default['opennms']['log4j2']['telemetryd'] = 'WARN'
default['opennms']['log4j2']['scriptd'] = 'WARN'
default['opennms']['log4j2']['snmp'] = 'WARN'
default['opennms']['log4j2']['snmp_poller'] = 'WARN'
default['opennms']['log4j2']['syslogd'] = 'WARN'
default['opennms']['log4j2']['threshd'] = 'WARN'
default['opennms']['log4j2']['tl1d'] = 'WARN'
default['opennms']['log4j2']['trapd'] = 'WARN'
default['opennms']['log4j2']['trouble_ticketer'] = 'WARN'
default['opennms']['log4j2']['vacuumd'] = 'WARN'
default['opennms']['log4j2']['web'] = 'WARN'
default['opennms']['log4j2']['xmlrpcd'] = 'WARN'
# microblog-configuration.xml
default['opennms']['microblog']['default_profile']['name']                = 'twitter' # or 'identica'
default['opennms']['microblog']['default_profile']['authen_username']     = 'yourusername' # relevant for identica only
default['opennms']['microblog']['default_profile']['authen_password']     = 'yourpassword' # relevant for identica only
default['opennms']['microblog']['default_profile']['oauth_ckey']          = nil # relevant for twitter only
default['opennms']['microblog']['default_profile']['oauth_csecret']       = nil # relevant for twitter only
default['opennms']['microblog']['default_profile']['oauth_atoken']        = nil # relevant for twitter only
default['opennms']['microblog']['default_profile']['oauth_atoken_secret'] = nil # relevant for twitter only
# model-importer.properties / provisiond-configuration.xml
default['opennms']['importer']['requisition_dir']    = "#{onms_home}/etc/imports"
default['opennms']['importer']['foreign_source_dir'] = "#{onms_home}/etc/foreign-sources"
default['opennms']['importer']['import_url']         = 'file:/path/to/dump.xml'
default['opennms']['importer']['schedule']           = '0 0 0 1 1 ? 2023'
default['opennms']['importer']['threads']            = 8
default['opennms']['importer']['scan_threads']       = 10
default['opennms']['importer']['rescan_threads']     = 10
default['opennms']['importer']['write_threads']      = 8
# modemConfig.properties
# NOTE: Predefined options are: mac2412, mac2414, macFA22, macFA24, macFA42, macFA44, acm0, acm1, acm2, acm3, acm4, acm5.
# To define your own, you'll need to populate custom_modem with the following keys defined: name, port, model, manufacturer, baudrate, and optionally pin. The defaults for all predefined modems are:
# port: /dev/tty(\.usbmodem)?#{name}
# model: w760i
# manufacturer: Sony Ericsson
# baudrate: 57600
default['opennms']['modem']['model'] = 'mac2412'
default['opennms']['custom_modem'] = nil
# notifd-configuration.xml
# set to 'on' or 'off' to override what is currently in the file
default['opennms']['notifd']['status'] = nil
# set to `true` or `false` to override what is currently in the file
default['opennms']['notifd']['match_all'] = nil
# nsclient-datacollection-config.xml
default['opennms']['nsclient_datacollection']['enable_default']                   = true
default['opennms']['nsclient_datacollection']['default']['rrd']['step']           = 300
default['opennms']['nsclient_datacollection']['default']['rrd']['rras']           = ['RRA:AVERAGE:0.5:1:2016', 'RRA:AVERAGE:0.5:12:1488', 'RRA:AVERAGE:0.5:288:366', 'RRA:MAX:0.5:288:366', 'RRA:MIN:0.5:288:366']
default['opennms']['nsclient_datacollection']['default']['processor']['enabled']  = true
default['opennms']['nsclient_datacollection']['default']['processor']['interval'] = 3_600_000
default['opennms']['nsclient_datacollection']['default']['system']['enabled'] = true
default['opennms']['nsclient_datacollection']['default']['system']['interval'] = 86_400_000
default['opennms']['nsclient_datacollection']['default']['iis']['enabled'] = true
default['opennms']['nsclient_datacollection']['default']['iis']['interval'] = 86_400_000
default['opennms']['nsclient_datacollection']['default']['exchange']['enabled'] = true
default['opennms']['nsclient_datacollection']['default']['exchange']['interval'] = 86_400_000
default['opennms']['nsclient_datacollection']['default']['dns']['enabled'] = true
default['opennms']['nsclient_datacollection']['default']['dns']['interval'] = 86_400_000
default['opennms']['nsclient_datacollection']['default']['sqlserver']['enabled'] = true
default['opennms']['nsclient_datacollection']['default']['sqlserver']['interval'] = 86_400_000
default['opennms']['nsclient_datacollection']['default']['biztalk']['enabled'] = true
default['opennms']['nsclient_datacollection']['default']['biztalk']['interval'] = 86_400_000
default['opennms']['nsclient_datacollection']['default']['live']['enabled'] = true
default['opennms']['nsclient_datacollection']['default']['live']['interval'] = 86_400_000
default['opennms']['nsclient_datacollection']['default']['mailmarshal']['enabled'] = true
default['opennms']['nsclient_datacollection']['default']['mailmarshal']['interval'] = 86_400_000
# poller-configuration.xml
default['opennms']['poller']['threads']                         = 30
default['opennms']['poller']['service_unresponsive_enabled']    = false
default['opennms']['poller']['node_outage']['status']           = 'on'
default['opennms']['poller']['node_outage']['critical_service'] = 'ICMP'
# reportd-configuration.xml
default['opennms']['reportd']['persist_reports'] = 'yes'
default['opennms']['reportd']['storage_location'] = "#{onms_home}/share/reports/"
# response adhoc graphs
default['opennms']['response_adhoc_graph']['command_prefix'] = nil # lets you customize the entire command prefix
# rrd-configuration.properties
default['opennms']['rrd']['strategy_class']                          = nil
default['opennms']['rrd']['interface_jar']                           = nil
default['opennms']['rrd']['jrrd']                                    = nil
default['opennms']['rrd']['file_extension']                          = nil
default['opennms']['rrd']['queue']['use']                            = true
default['opennms']['rrd']['queue']['writethreads']                   = 2
default['opennms']['rrd']['queue']['queuecreates']                   = false
default['opennms']['rrd']['queue']['prioritize_significant_updates'] = false
default['opennms']['rrd']['queue']['max_insig_update_seconds']       = 0
default['opennms']['rrd']['queue']['modulus']                        = 10_000
default['opennms']['rrd']['queue']['insig_hwmark']                   = 0
default['opennms']['rrd']['queue']['sig_hwmark']                     = 0
default['opennms']['rrd']['queue']['queue_hwmark']                   = 0
default['opennms']['rrd']['queue']['log_cat']                        = nil
default['opennms']['rrd']['queue']['write_thread']['sleep_time']     = 50
default['opennms']['rrd']['queue']['write_thread']['exit_delay']     = 60_000
default['opennms']['rrd']['jrobin']['backend_factory']               = nil
default['opennms']['rrd']['usetcp']                                  = false
default['opennms']['rrd']['tcp']['host']                             = nil
default['opennms']['rrd']['tcp']['port']                             = nil
# rtc-configuration.xml
default['opennms']['rtc']['updaters']                      = 10
default['opennms']['rtc']['senders']                       = 5
default['opennms']['rtc']['rolling_window']                = '24h'
default['opennms']['rtc']['max_events_before_resend']      = 100
default['opennms']['rtc']['low_threshold_interval']        = '20s'
default['opennms']['rtc']['high_threshold_interval']       = '45s'
default['opennms']['rtc']['user_refresh_interval']         = '2m'
default['opennms']['rtc']['errors_before_url_unsubscribe'] = 5
# site-status-views.xml
default['opennms']['site_status_views']['default_view']['name'] = 'default'
# Array of single element hashes of {label => name}, like [{"Routers" => "Routers"}, {"Switches" => "Switches"}, {"Servers" => "Servers"}]
# which duplicates the default setting.
# If it was just be a single hash but then you wouldn't get defined ordering of elements.
default['opennms']['site_status_views']['default_view']['rows'] = nil
# smsPhonebook.properties
default['opennms']['sms_phonebook']['entries'] = { '127.0.0.1' => '+19195551212' }
# snmp-adhoc-graph.properties
default['opennms']['snmp_adhoc_graph']['image_format'] = 'png' # or gif, or jpg, but png is te only cross-tool compatible format
default['opennms']['snmp_adhoc_graph']['command_prefix'] = nil # lets you customize entire command prefix
# snmp-interface-poller-configuration.xml
default['opennms']['snmp_iface_poller']['threads']                               = 30
default['opennms']['snmp_iface_poller']['service']                               = 'SNMP'
default['opennms']['snmp_iface_poller']['upvalues'] = 1
default['opennms']['snmp_iface_poller']['downvalues'] = 2
# array of service names
default['opennms']['snmp_iface_poller']['node_outage']                           = %w(ICMP SNMP)
default['opennms']['snmp_iface_poller']['example1']['filter']                    = "IPADDR != '0.0.0.0'"
default['opennms']['snmp_iface_poller']['example1']['ipv4_range']['begin']       = '1.1.1.1'
default['opennms']['snmp_iface_poller']['example1']['ipv4_range']['end']         = '1.1.1.1'
default['opennms']['snmp_iface_poller']['example1']['ipv6_range']['begin']       = '::1'
default['opennms']['snmp_iface_poller']['example1']['ipv6_range']['end']         = '::1'
default['opennms']['snmp_iface_poller']['example1']['interface']['name']         = 'Ethernet'
default['opennms']['snmp_iface_poller']['example1']['interface']['criteria']     = 'snmpiftype = 6'
default['opennms']['snmp_iface_poller']['example1']['interface']['interval']     = 300_000
default['opennms']['snmp_iface_poller']['example1']['interface']['user_defined'] = false
default['opennms']['snmp_iface_poller']['example1']['interface']['status']       = 'on'
# statsd-configuration.xml
default['opennms']['statsd']['throughput']['top_n_inOctets']               = false
default['opennms']['statsd']['response_time_reports']['top_10_weekly']     = false
default['opennms']['statsd']['response_time_reports']['top_10_this_month'] = false
default['opennms']['statsd']['response_time_reports']['top_10_last_month'] = false
default['opennms']['statsd']['response_time_reports']['top_10_this_year']  = false
# surveillance-views.xml
default['opennms']['surveillance_views']['default_view'] = 'default'
default['opennms']['surveillance_views']['default']      = true
# syslog-northbounder-configuration.xml
default['opennms']['syslog_north']['use_defaults']       = true
default['opennms']['syslog_north']['enabled']            = false
default['opennms']['syslog_north']['nagles_delay']       = 1000
default['opennms']['syslog_north']['batch_size']         = 100
default['opennms']['syslog_north']['queue_size']         = 300_000
default['opennms']['syslog_north']['message_format']     = 'ALARM ID:${alarmId} NODE:${nodeLabel}; ${logMsg}'
default['opennms']['syslog_north']['destination']['name']            = 'localTest'
default['opennms']['syslog_north']['destination']['host']            = '127.0.0.1'
default['opennms']['syslog_north']['destination']['port']            = '514'
default['opennms']['syslog_north']['destination']['ip_protocol']     = 'UDP'
default['opennms']['syslog_north']['destination']['facility']        = 'LOCAL0'
default['opennms']['syslog_north']['destination']['max_length']      = 1024
default['opennms']['syslog_north']['destination']['send_local_name'] = true
default['opennms']['syslog_north']['destination']['send_local_time'] = true
default['opennms']['syslog_north']['destination']['truncate']        = false
default['opennms']['syslog_north']['uei']['node_down'] = false
default['opennms']['syslog_north']['uei']['node_up']   = false
# syslogd-configuration.xml
default['opennms']['syslogd']['port']                   = nil
default['opennms']['syslogd']['new_suspect']            = nil
default['opennms']['syslogd']['parser']                 = nil
default['opennms']['syslogd']['forwarding_regexp']      = nil
default['opennms']['syslogd']['matching_group_host']    = nil
default['opennms']['syslogd']['matching_group_message'] = nil
default['opennms']['syslogd']['discard_uei']            = nil
default['opennms']['syslogd']['timezone']               = nil
# threshd-configuration.xml
# set to overwrite current value in file
default['opennms']['threshd']['threads'] = nil
# translator-configuration.xml
default['opennms']['translator']['snmp_link_down']                = true
default['opennms']['translator']['snmp_link_up']                  = true
default['opennms']['translator']['hyperic']                       = true
default['opennms']['translator']['cisco_config_man']              = true
default['opennms']['translator']['juniper_cfg_change']            = true
default['opennms']['translator']['telemetry_clock_skew_detected'] = true
# trapd-configuration.xml
default['opennms']['trapd']['port']        = 10162
default['opennms']['trapd']['new_suspect'] = false
# vacuumd-configuration.xml
default['opennms']['vacuumd']['period']                             = 86_400_000
default['opennms']['vacuumd']['statement']['topo_delete_nodes']     = true
default['opennms']['vacuumd']['statement']['delete_at_interfaces']  = true
default['opennms']['vacuumd']['statement']['delete_dl_interfaces']  = true
default['opennms']['vacuumd']['statement']['delete_ipr_interfaces'] = true
default['opennms']['vacuumd']['statement']['delete_vlans']          = true
default['opennms']['vacuumd']['statement']['delete_stp_interfaces'] = true
default['opennms']['vacuumd']['statement']['delete_stp_nodes']      = true
default['opennms']['vacuumd']['statement']['delete_snmp_interfaces'] = true
default['opennms']['vacuumd']['statement']['delete_nodes']          = true
default['opennms']['vacuumd']['statement']['delete_ip_interfaces']  = true
default['opennms']['vacuumd']['statement']['delete_if_services']    = true
default['opennms']['vacuumd']['statement']['delete_events']         = true
default['opennms']['vacuumd']['statement']['delete_values_json_key']               = true
default['opennms']['vacuumd']['statement']['delete_values_blob_key']               = true
default['opennms']['vacuumd']['automations']['cosmic_clear']                       = true
default['opennms']['vacuumd']['automations']['clean_up']                           = true
default['opennms']['vacuumd']['automations']['full_clean_up']                      = true
default['opennms']['vacuumd']['automations']['gc']                                 = true
default['opennms']['vacuumd']['automations']['full_gc']                            = true
default['opennms']['vacuumd']['automations']['unclear']                            = true
default['opennms']['vacuumd']['automations']['escalation']                         = true
default['opennms']['vacuumd']['automations']['purge_statistics_reports']           = true
default['opennms']['vacuumd']['automations']['clear_path_outages']                 = true
default['opennms']['vacuumd']['automations']['create_tickets']                     = true
default['opennms']['vacuumd']['automations']['create_critical_ticket']             = true
default['opennms']['vacuumd']['automations']['update_tickets']                     = true
default['opennms']['vacuumd']['automations']['close_cleared_alarm_tickets']        = true
default['opennms']['vacuumd']['automations']['clear_alarms_for_closed_tickets']    = true
default['opennms']['vacuumd']['automations']['clean_up_rp_status_changes']         = true
default['opennms']['vacuumd']['automations']['maintenance_check']                  = false
default['opennms']['vacuumd']['automations']['access_points_table']                = false
default['opennms']['vacuumd']['triggers']['select_closed_ticket_state_for_problem_alarms'] = true
default['opennms']['vacuumd']['triggers']['select_null_ticket_state_alarms']               = true
default['opennms']['vacuumd']['triggers']['select_critial_open_alarms']                    = true
default['opennms']['vacuumd']['triggers']['select_not_null_ticket_state_alarms']           = true
default['opennms']['vacuumd']['triggers']['select_cleared_alarm_with_open_ticket_state']   = true
default['opennms']['vacuumd']['triggers']['select_suspect_alarms']                         = true
default['opennms']['vacuumd']['triggers']['select_cleared_alarms']                         = true
default['opennms']['vacuumd']['triggers']['select_resolvers']                              = true
default['opennms']['vacuumd']['triggers']['select_expiration_maintenance']                 = false
default['opennms']['vacuumd']['triggers']['select_access_points_missing_from_table']       = false
default['opennms']['vacuumd']['triggers']['select_past_cleared_alarms']          = true
default['opennms']['vacuumd']['triggers']['select_all_past_cleared_alarms']      = true
default['opennms']['vacuumd']['triggers']['select_alarms_to_gc']                 = true
default['opennms']['vacuumd']['triggers']['select_alarms_to_full_gc']            = true
default['opennms']['vacuumd']['triggers']['select_path_outages_nodes']           = true
default['opennms']['vacuumd']['actions']['acknowledge_alarm']                    = true
default['opennms']['vacuumd']['actions']['update_automation_time']               = true
default['opennms']['vacuumd']['actions']['escalate_alarm']                       = true
default['opennms']['vacuumd']['actions']['reset_severity']                       = true
default['opennms']['vacuumd']['actions']['garbage_collect_7_4']                  = true
default['opennms']['vacuumd']['actions']['garbage_collect_8_1']                  = false
default['opennms']['vacuumd']['actions']['full_garbage_collect_7_4']             = true
default['opennms']['vacuumd']['actions']['full_garbage_collect_8_1']             = false
default['opennms']['vacuumd']['actions']['delete_past_cleared_alarms']           = true
default['opennms']['vacuumd']['actions']['delete_all_past_cleared_alarms']       = true
default['opennms']['vacuumd']['actions']['clear_problems']                       = true
default['opennms']['vacuumd']['actions']['clear_closed_ticket_alarms']           = true
default['opennms']['vacuumd']['actions']['delete_purgeable_statistics_reports']  = true
default['opennms']['vacuumd']['actions']['do_nothing_action']                    = true
default['opennms']['vacuumd']['actions']['clean_up_rp_status_changes']           = true
default['opennms']['vacuumd']['actions']['maintenance_expiration_warning']       = false
default['opennms']['vacuumd']['actions']['access_points_table']                  = false
default['opennms']['vacuumd']['actions']['clear_path_outages']                   = true
default['opennms']['vacuumd']['auto_events']['escalation_event']                 = true
default['opennms']['vacuumd']['action_events']['create_ticket']                  = true
default['opennms']['vacuumd']['action_events']['update_ticket']                  = true
default['opennms']['vacuumd']['action_events']['close_ticket']                   = true
default['opennms']['vacuumd']['action_events']['event_escalated']                = true
default['opennms']['vacuumd']['action_events']['maintenance_expiration_warning'] = false
# vmware-cim-datacollection-config.xml
default['opennms']['vmware_cim']['default_esx_hostsystem']['rrd']['step']              = 300
default['opennms']['vmware_cim']['default_esx_hostsystem']['rrd']['rras']              = ['RRA:AVERAGE:0.5:1:2016', 'RRA:AVERAGE:0.5:12:1488', 'RRA:AVERAGE:0.5:288:366', 'RRA:MAX:0.5:288:366', 'RRA:MIN:0.5:288:366']
default['opennms']['vmware_cim']['default_esx_hostsystem']['sensor_unknown']           = true
default['opennms']['vmware_cim']['default_esx_hostsystem']['sensor_other']             = true
default['opennms']['vmware_cim']['default_esx_hostsystem']['sensor_temperature']       = true
default['opennms']['vmware_cim']['default_esx_hostsystem']['sensor_voltage']           = true
default['opennms']['vmware_cim']['default_esx_hostsystem']['sensor_current']           = true
default['opennms']['vmware_cim']['default_esx_hostsystem']['sensor_counter'] = true
default['opennms']['vmware_cim']['default_esx_hostsystem']['sensor_tachometer']        = true
default['opennms']['vmware_cim']['default_esx_hostsystem']['sensor_switch']            = true
default['opennms']['vmware_cim']['default_esx_hostsystem']['sensor_lock']              = true
default['opennms']['vmware_cim']['default_esx_hostsystem']['sensor_humidity']          = true
default['opennms']['vmware_cim']['default_esx_hostsystem']['sensor_smoke_detection']   = true
default['opennms']['vmware_cim']['default_esx_hostsystem']['sensor_presence']          = true
default['opennms']['vmware_cim']['default_esx_hostsystem']['sensor_airflow']           = true
default['opennms']['vmware_cim']['default_esx_hostsystem']['sensor_power_consumption'] = true
default['opennms']['vmware_cim']['default_esx_hostsystem']['sensor_power_production']  = true
default['opennms']['vmware_cim']['default_esx_hostsystem']['sensor_pressure'] = true
# vmware-datacollection-config.xml
default['opennms']['vmware']['default_hostsystem3']['enabled']       = true
default['opennms']['vmware']['default_hostsystem3']['rrd']['step']   = 300
default['opennms']['vmware']['default_hostsystem3']['rrd']['rras']   = ['RRA:AVERAGE:0.5:1:2016', 'RRA:AVERAGE:0.5:12:1488', 'RRA:AVERAGE:0.5:288:366', 'RRA:MAX:0.5:288:366', 'RRA:MIN:0.5:288:366']
default['opennms']['vmware']['default_hostsystem3']['vmware3_cpu']    = true
default['opennms']['vmware']['default_hostsystem3']['vmware3_node']   = true
default['opennms']['vmware']['default_hostsystem3']['vmware3_mgt_agt'] = true
default['opennms']['vmware']['default_hostsystem3']['vmware3_net']    = true
default['opennms']['vmware']['default_hostsystem3']['vmware3_disk']   = true
default['opennms']['vmware']['default_hostsystem3']['vmware3_sys']    = true
default['opennms']['vmware']['default_vm3']['enabled']               = true
default['opennms']['vmware']['default_vm3']['rrd']['step']           = 300
default['opennms']['vmware']['default_vm3']['rrd']['rras']           = ['RRA:AVERAGE:0.5:1:2016', 'RRA:AVERAGE:0.5:12:1488', 'RRA:AVERAGE:0.5:288:366', 'RRA:MAX:0.5:288:366', 'RRA:MIN:0.5:288:366']
default['opennms']['vmware']['default_vm3']['vmware3_cpu']            = true
default['opennms']['vmware']['default_vm3']['vmware3_node']           = true
default['opennms']['vmware']['default_vm3']['vmware3_net']            = true
default['opennms']['vmware']['default_vm3']['vmware3_disk']           = true
default['opennms']['vmware']['default_hostsystem4']['enabled']       = true
default['opennms']['vmware']['default_hostsystem4']['rrd']['step']   = 300
default['opennms']['vmware']['default_hostsystem4']['rrd']['rras']   = ['RRA:AVERAGE:0.5:1:2016', 'RRA:AVERAGE:0.5:12:1488', 'RRA:AVERAGE:0.5:288:366', 'RRA:MAX:0.5:288:366', 'RRA:MIN:0.5:288:366']
default['opennms']['vmware']['default_hostsystem4']['vmware4_cpu']    = true
default['opennms']['vmware']['default_hostsystem4']['vmware4_node']   = true
default['opennms']['vmware']['default_hostsystem4']['vmware4_mgt_agt'] = true
default['opennms']['vmware']['default_hostsystem4']['vmware4_net']    = true
default['opennms']['vmware']['default_hostsystem4']['vmware4_disk']   = true
default['opennms']['vmware']['default_hostsystem4']['vmware4_sys']    = true
default['opennms']['vmware']['default_vm4']['enabled']               = true
default['opennms']['vmware']['default_vm4']['rrd']['step']           = 300
default['opennms']['vmware']['default_vm4']['rrd']['rras']           = ['RRA:AVERAGE:0.5:1:2016', 'RRA:AVERAGE:0.5:12:1488', 'RRA:AVERAGE:0.5:288:366', 'RRA:MAX:0.5:288:366', 'RRA:MIN:0.5:288:366']
default['opennms']['vmware']['default_vm4']['vmware4_cpu']            = true
default['opennms']['vmware']['default_vm4']['vmware4_node']           = true
default['opennms']['vmware']['default_vm4']['vmware4_net']            = true
default['opennms']['vmware']['default_vm4']['vmware4_disk']           = true
default['opennms']['vmware']['default_hostsystem5']['enabled']       = true
default['opennms']['vmware']['default_hostsystem5']['rrd']['step']   = 300
default['opennms']['vmware']['default_hostsystem5']['rrd']['rras']   = ['RRA:AVERAGE:0.5:1:2016', 'RRA:AVERAGE:0.5:12:1488', 'RRA:AVERAGE:0.5:288:366', 'RRA:MAX:0.5:288:366', 'RRA:MIN:0.5:288:366']
default['opennms']['vmware']['default_hostsystem5']['vmware5_st_adptr'] = true
default['opennms']['vmware']['default_hostsystem5']['vmware5_cpu']    = true
default['opennms']['vmware']['default_hostsystem5']['vmware5_node']   = true
default['opennms']['vmware']['default_hostsystem5']['vmware5_mgt_agt'] = true
default['opennms']['vmware']['default_hostsystem5']['vmware5_net']    = true
default['opennms']['vmware']['default_hostsystem5']['vmware5_disk']   = true
default['opennms']['vmware']['default_hostsystem5']['vmware5_st_pth']  = true
default['opennms']['vmware']['default_hostsystem5']['vmware5_da_st']   = true
default['opennms']['vmware']['default_hostsystem5']['vmware5_sys'] = true
default['opennms']['vmware']['default_vm5']['enabled']               = true
default['opennms']['vmware']['default_vm5']['rrd']['step']           = 300
default['opennms']['vmware']['default_vm5']['rrd']['rras']           = ['RRA:AVERAGE:0.5:1:2016', 'RRA:AVERAGE:0.5:12:1488', 'RRA:AVERAGE:0.5:288:366', 'RRA:MAX:0.5:288:366', 'RRA:MIN:0.5:288:366']
default['opennms']['vmware']['default_vm5']['vmware5_cpu']            = true
default['opennms']['vmware']['default_vm5']['vmware5_node']           = true
default['opennms']['vmware']['default_vm5']['vmware5_net']            = true
default['opennms']['vmware']['default_vm5']['vmware5_vrt_disk'] = true
default['opennms']['vmware']['default_vm5']['vmware5_disk'] = true
default['opennms']['vmware']['default_vm5']['vmware5_da_st'] = true
# xmpp-configuration.properties
default['opennms']['xmpp']['server']              = nil
default['opennms']['xmpp']['service_name']        = nil
default['opennms']['xmpp']['port']                = nil
default['opennms']['xmpp']['tls']                 = nil
default['opennms']['xmpp']['sasl']                = nil
default['opennms']['xmpp']['self_signed_certs']   = nil
default['opennms']['xmpp']['truststore_password'] = nil
default['opennms']['xmpp']['debug']               = nil
default['opennms']['xmpp']['user']                = nil
default['opennms']['xmpp']['pass']                = nil

default['opennms']['repos']['branches'] = %w(obsolete snapshot stable oldstable)
default['opennms']['repos']['platforms'] = %w(common rhel9)
# add a specific version vault repo like this:
# node['opennms']['repos']['vault'] = ['32.0.6']
default['opennms']['repos']['vault'] = []

default['opennms']['telemetryd']['managed'] = false
default['opennms']['telemetryd']['jti']['enabled'] = false
default['opennms']['telemetryd']['jti']['port'] = 50000
default['opennms']['telemetryd']['netflow5']['enabled'] = false
default['opennms']['telemetryd']['netflow5']['port'] = 8877
default['opennms']['telemetryd']['netflow9']['enabled'] = false
default['opennms']['telemetryd']['netflow9']['port'] = 4729
default['opennms']['telemetryd']['ipfix']['enabled'] = false
default['opennms']['telemetryd']['ipfix']['port'] = 4730
default['opennms']['telemetryd']['sflow']['enabled'] = false
default['opennms']['telemetryd']['sflow']['port'] = 6343
default['opennms']['telemetryd']['nxos']['enabled'] = false
default['opennms']['telemetryd']['nxos']['port'] = 50001
# 'protocol_name' => {
#   'description' => 'xxx',
#   'enabled' => true|false,
#   'listeners' => {
#     'listener_name' => {
#       'class_name' => 'org.opennms.blah.blah',
#       'parameters' => {
#         'key' => 'value',
#         ...
#       }
#      },
#      ...
#    },
#    ...
#    'adapters' => {
#      'adapter_name' => {
#        'class_name' => 'org.opennms.blah.blah',
#        'parameters' => {
#          'key' => 'value',
#         ...
#        }
#      },
#      ...
#    },
#    'package' => {
#      'rrd' => {
#        'step' => 300,
#        'rras' => ['strings'],
#      }
#    }
# },
# ...
default['opennms']['telemetryd']['protocols'] = {}
default['opennms']['telemetryd']['cookbook'] = 'opennms'
default['opennms']['es']['hosts'] = {}
default['opennms']['manage_repos'] = true

default['opennms']['postgresql']['setup_repo'] = true
default['opennms']['postgresql']['version'] = '15'
# must contain objects named 'postgres' and 'opennms' each with string values named 'password'
default['opennms']['postgresql']['user_vault'] = Chef::Config['node_name']
default['opennms']['postgresql']['user_vault_item'] = 'postgres_users'
default['opennms']['postgresql']['access']['host'] = [
  {
    'database' => 'all',
    'user' => 'all',
    'addresses' => ['127.0.0.1/32', '::1/128'],
    'auth_method' => 'scram-sha-256',
    'action' => :create,
  },
  {
    'database' => 'replication',
    'user' => 'all',
    'addresses' => ['127.0.0.1/32', '::1/128'],
    'auth_method' => 'trust',
    'action' => :delete,
  },
]
default['opennms']['postgresql']['access']['local'] = [
  {
    'database' => 'all',
    'user' => 'all',
    'auth_method' => 'scram-sha-256',
    'action' => :create,
  },
  {
    'database' => 'replication',
    'user' => 'all',
    'auth_method' => 'trust',
    'action' => :create,
  },
]
default['opennms']['postgresql']['local_auth_method'] = 'scram-sha-256'
default['opennms']['postgresql']['local_repl_auth_method'] = 'trust'

default['opennms']['bin']['cookbook'] = 'opennms'
default['opennms']['bin']['return_code'] = false
default['opennms']['rrdtool']['enabled'] = false

# values for opennms-datasources.xml
default['opennms']['datasources_cookbook'] = 'opennms'
default['opennms']['datasources']['connection_pool'] = {
  'idle_timeout' => 600,
  'login_timeout' => 3,
  'min_pool' => 25,
  'max_pool' => 50,
  'max_size' => 50,
}
default['opennms']['datasources']['opennms'] = {
  'database_name' => 'opennms',
  'class_name' => 'org.postgresql.Driver',
  'url' => 'jdbc:postgresql://localhost:5432/opennms',
  'user_name' => '${scv:postgres:username|opennms}',
  'password' => '${scv:postgres:password|opennms}',
}
default['opennms']['datasources']['opennms-admin'] = {
  'database_name' => 'template1',
  'class_name' => 'org.postgresql.Driver',
  'url' => 'jdbc:postgresql://localhost:5432/template1',
  'user_name' => '${scv:postgres-admin:username|postgres}',
  'password' => '${scv:postgres-admin:password|}',
  'connection_pool' => {
    'idle_timeout' => 600,
    'min_pool' => 0,
    'max_pool' => 10,
    'max_size' => 50,
  },
}
default['opennms']['datasources']['opennms-monitor'] = {
  'database_name' => 'postgres',
  'class_name' => 'org.postgresql.Driver',
  'url' => 'jdbc:postgresql://localhost:5432/postgres',
  'user_name' => '${scv:postgres-admin:username|postgres}',
  'password' => '${scv:postgres-admin:password|}',
  'connection_pool' => {
    'idle_timeout' => 600,
    'min_pool' => 0,
    'max_pool' => 10,
    'max_size' => 50,
  },
}
default['opennms']['scv']['vault'] = Chef::Config['node_name']
default['opennms']['scv']['item'] = 'scv'

# OOTB eventconf files. See documentation/eventconf.md for details
default['opennms']['opennms_event_files'] = [
              'opennms.snmp.trap.translator.events.xml',
              'opennms.ackd.events.xml',
              'opennms.alarm.events.xml',
              'opennms.bmp.events.xml',
              'opennms.bsm.events.xml',
              'opennms.capsd.events.xml',
              'opennms.collectd.events.xml',
              'opennms.config.events.xml',
              'opennms.correlation.events.xml',
              'opennms.default.threshold.events.xml',
              'opennms.discovery.events.xml',
              'opennms.hyperic.events.xml',
              'opennms.internal.events.xml',
              'opennms.linkd.events.xml',
              'opennms.mib.events.xml',
              'opennms.pollerd.events.xml',
              'opennms.provisioning.events.xml',
              'opennms.minion.events.xml',
              'opennms.perspective.poller.events.xml',
              'opennms.reportd.events.xml',
              'opennms.syslogd.events.xml',
              'opennms.ticketd.events.xml',
              'opennms.tl1d.events.xml',
]
default['opennms']['vendor_event_files'] = [
              'GraphMLAssetPluginEvents.xml',
              '3Com.events.xml',
              'AdaptecRaid.events.xml',
              'ADIC-v2.events.xml',
              'Adtran.events.xml',
              'Adtran.Atlas.events.xml',
              'Aedilis.events.xml',
              'AirDefense.events.xml',
              'AIX.events.xml',
              'AKCP.events.xml',
              'AlcatelLucent.OmniSwitch.events.xml',
              'AlcatelLucent.SMSBrick.events.xml',
              'Allot.events.xml',
              'Allot.NetXplorer.events.xml',
              'Allot.SM.events.xml',
              'Alteon.events.xml',
              'Altiga.events.xml',
              'APC.events.xml',
              'APC.Best.events.xml',
              'APC.Exide.events.xml',
              'ApacheHTTPD.syslog.events.xml',
              'Aruba.AP.events.xml',
              'Aruba.Switch.events.xml',
              'Aruba.events.xml',
              'Ascend.events.xml',
              'ASYNCOS-MAIL-MIB.events.xml',
              'Avocent.ACS.events.xml',
              'Avocent.ACS5000.events.xml',
              'Avocent.AMX5000.events.xml',
              'Avocent.AMX5010.events.xml',
              'Avocent.AMX5020.events.xml',
              'Avocent.AMX5030.events.xml',
              'Avocent.CCM.events.xml',
              'Avocent.DSR.events.xml',
              'Avocent.DSR1021.events.xml',
              'Avocent.DSR2010.events.xml',
              'Avocent-DSView.events.xml',
              'Avocent.Mergepoint.events.xml',
              'Avocent.PMTrap.events.xml',
              'Audiocodes.events.xml',
              'A10.AX.events.xml',
              'ATMForum.events.xml',
              'BackupExec.events.xml',
              'BEA.events.xml',
              'BGP4.events.xml',
              'BladeNetwork.events.xml',
              'Bluecat.events.xml',
              'BlueCoat.events.xml',
              'Brocade.events.xml',
              'Broadcom-BASPTrap.events.xml',
              'CA.ArcServe.events.xml',
              'Ceragon-FA1500.events.xml',
              'Cisco.airespace.xml',
              'Cisco.CIDS.events.xml',
              'Cisco.5300dchan.events.xml',
              'Cisco.mcast.events.xml',
              'Cisco.SCE.events.xml',
              'Cisco2.events.xml',
              'Cisco.events.xml',
              'CitrixNetScaler.events.xml',
              'Colubris.events.xml',
              'ComtechEFData.events.xml',
              'Concord.events.xml',
              'Covergence.events.xml',
              'CPQHPIM.events.xml',
              'Clarent.events.xml',
              'Clarinet.events.xml',
              'Clavister.events.xml',
              'Compuware.events.xml',
              'Cricket.events.xml',
              'CRITAPP.events.xml',
              'Crossbeam.events.xml',
              'Dell-Asf.events.xml',
              'DellArrayManager.events.xml',
              'DellEquallogic.events.xml',
              'Dell-DRAC2.events.xml',
              'Dell-ITassist.events.xml',
              'Dell-F10-bgb4-v2.events.xml',
              'Dell-F10-chassis.events.xml',
              'Dell-F10-copy-config.events.xml',
              'Dell-F10-mstp.events.xml',
              'Dell-F10-system-component.events.xml',
              'DellOpenManage.events.xml',
              'DellRacHost.events.xml',
              'DellStorageManagement.events.xml',
              'DISMAN.events.xml',
              'DISMAN-PING.events.xml',
              'Dlink.events.xml',
              'DMTF.events.xml',
              'DPS.events.xml',
              'DS1.events.xml',
              'EMC.events.xml',
              'EMC-Celerra.events.xml',
              'EMC-Clariion.events.xml',
              'Evertz.7780ASI-IP2.events.xml',
              'Evertz.7880IP-ASI-IP.events.xml',
              'Evertz.7880IP-ASI-IP-FR.events.xml',
              'Evertz.7881DEC-MP2-HD.events.xml',
              'Extreme.events.xml',
              'F5.events.xml',
              'fcmgmt.events.xml',
              'Fore.events.xml',
              'Fortinet-FortiCore-v52.events.xml',
              'Fortinet-FortiGate-v52.events.xml',
              'Fortinet-FortiMail.events.xml',
              'Fortinet-FortiManager-Analyzer.events.xml',
              'Fortinet-FortiRecorder.events.xml',
              'Fortinet-FortiVoice.events.xml',
              'Fortinet-FortiCore-v4.events.xml',
              'Fortinet-FortiGate-v4.events.xml',
              'FoundryNetworks.events.xml',
              'FoundryNetworks2.events.xml',
              'FujitsuSiemens.events.xml',
              'GGSN.events.xml',
              'Groupwise.events.xml',
              'HP.events.xml',
              'HWg.Poseidon.events.xml',
              'Hyperic.events.xml',
              'IBM.events.xml',
              'IBM-UMS.events.xml',
              'IBMRSA2.events.xml',
              'IBM.EIF.events.xml',
              'IEEE802dot11.events.xml',
              'ietf.dlsw.events.xml',
              'ietf.docsis.events.xml',
              'ietf.events.xml',
              'ietf.ptopo.events.xml',
              'ietf.sna-dlc.events.xml',
              'ietf.tn3270e.events.xml',
              'ietf.vrrp.events.xml',
              'Infoblox.events.xml',
              'Intel.events.xml',
              'INTEL-LAN-ADAPTERS-MIB.events.xml',
              'InteractiveIntelligence.events.xml',
              'IronPort.events.xml',
              'ISS.events.xml',
              'IPUnity-SES-MIB.events.xml',
              'IPV6.events.xml',
              'Juniper.mcast.events.xml',
              'Juniper.events.xml',
              'Juniper.ive.events.xml',
              'Juniper.screen.events.xml',
              'Junos.events.xml',
              'JunosV1.events.xml',
              'K5Systems.events.xml',
              'Konica.events.xml',
              'LLDP.events.xml',
              'Liebert.events.xml',
              'Liebert.600SM.events.xml',
              'Linksys.events.xml',
              'LinuxKernel.syslog.events.xml',
              'Lucent.events.xml',
              'MadgeNetworks.events.xml',
              'McAfee.events.xml',
              'MGE-UPS.events.xml',
              'Microsoft.events.xml',
              'MikrotikRouterOS.events.xml',
              'Multicast.standard.events.xml',
              'MPLS.events.xml',
              'MRV.events.xml',
              'MSDP.events.xml',
              'Mylex.events.xml',
              'NetApp.events.xml',
              'Netbotz.events.xml',
              'Netgear.events.xml',
              'NetgearProsafeSmartSwitch.events.xml',
              'NetgearProsafeSmartSwitch.syslog.events.xml',
              'Netscreen.events.xml',
              'NetSNMP.events.xml',
              'Nokia.events.xml',
              'NORTEL.Contivity.events.xml',
              'Novell.events.xml',
              'OpenSSH.syslog.events.xml',
              'OpenWrt.syslog.events.xml',
              'Oracle.events.xml',
              'OSPF.events.xml',
              'Overland.events.xml',
              'Overture.events.xml',
              'Procmail.syslog.events.xml',
              'POSIX.syslog.events.xml',
              'Postfix.syslog.events.xml',
              'Packeteer.events.xml',
              'Patrol.events.xml',
              'PCube.events.xml',
              'Pingtel.events.xml',
              'Pixelmetrix.events.xml',
              'Polycom.events.xml',
              'Powerware.events.xml',
              'Primecluster.events.xml',
              'Quintum.events.xml',
              'Raytheon.events.xml',
              'RADLAN-MIB.events.xml',
              'RAPID-CITY.events.xml',
              'Redline.events.xml',
              'RFC1382.events.xml',
              'RFC1628.events.xml',
              'Rightfax.events.xml',
              'RiverbedSteelhead.events.xml',
              'RMON.events.xml',
              'Sensaphone.events.xml',
              'Sentry.events.xml',
              'Siemens-HiPath3000.events.xml',
              'Siemens-HiPath3000-HG1500.events.xml',
              'Siemens-HiPath4000.events.xml',
              'Siemens-HiPath8000-OpenScapeVoice.events.xml',
              'SNA-NAU.events.xml',
              'SNMP-REPEATER.events.xml',
              'Snort.events.xml',
              'SonicWall.events.xml',
              'Sonus.events.xml',
              'Sudo.syslog.events.xml',
              'SunILOM.events.xml',
              'Symbol.events.xml',
              'Syslogd.events.xml',
              'SystemEdge.events.xml',
              'SwissQual.events.xml',
              'TransPath.events.xml',
              'Trendmicro.events.xml',
              'TrippLite.events.xml',
              'TUT.events.xml',
              'UPS-MIB.events.xml',
              'Uptime.events.xml',
              'Veeam_Backup-Replication.events.xml',
              'Veraz.events.xml',
              'VMWare.env.events.xml',
              'VMWare.vc.events.xml',
              'VMWare.vminfo.events.xml',
              'VMWare.obsolete.events.xml',
              'VMWare.events.xml',
              'Waverider.3000.events.xml',
              'Websense.events.xml',
              'Xerox-V2.events.xml',
              'Xerox.events.xml',
]
default['opennms']['catch_all_event_file'] = 'opennms.catch-all.events.xml'
default['opennms']['secure_fields'] = %w(
              logmsg
              operaction
              autoaction
              tticket
              script
)
default['opennms']['manage_collection_packages'] = false
default['opennms']['manage_jdbc_collections'] = false
default['opennms']['manage_jmx_collections'] = false
default['opennms']['manage_snmp_collections'] = false
default['opennms']['manage_xml_collections'] = false

# yum repo stuff
default['yum']['opennms']['key_url']                      = "http://yum.opennms.org/OPENNMS-GPG-KEY"
default['yum']['opennms-stable-common']['baseurl']        = "http://yum.opennms.org/stable/common"
default['yum']['opennms-stable-common']['failovermethod'] = "roundrobin"
default['yum']['opennms-stable-rhel6']['baseurl']         = "http://yum.opennms.org/stable/rhel6"
default['yum']['opennms-stable-rhel6']['failovermethod']  = "roundrobin"

# opennms.conf
default['opennms']['conf']['home']           = "/opt/opennms"
default['opennms']['conf']['pidfile']        = "#{default['opennms']['conf']['home']}/logs/daemon/opennms.pid"
default['opennms']['conf']['logdir']         = "#{default['opennms']['conf']['home']}/logs/daemon"
default['opennms']['conf']['initdir']        = "#{default['opennms']['conf']['home']}/bin"
default['opennms']['conf']['redirect']       = "$LOG_DIRECTORY/output.log"
default['opennms']['conf']['start_timeout']  = 10
default['opennms']['conf']['status_wait']    = 5
default['opennms']['conf']['heap_size']      = 512
default['opennms']['conf']['addl_mgr_opts']  = ""
default['opennms']['conf']['addl_classpath'] = ""
default['opennms']['conf']['use_incgc']      = ""
default['opennms']['conf']['hotspot']        = ""
default['opennms']['conf']['verbose_gc']     = ""
default['opennms']['conf']['runjava_opts']   = ""
default['opennms']['conf']['invoke_url']     = "http://127.0.0.1:8181/invoke?objectname=OpenNMS:Name=Manager"
default['opennms']['conf']['runas']          = "root"
default['opennms']['conf']['max_file_descr'] = "20480"
default['opennms']['conf']['command']        = "8192"

# opennms.properties
# ICMP
default['opennms']['properties']['icmp']['pinger_class'] = "org.opennms.netmgt.icmp.jni6.Jni6Pinger"
default['opennms']['properties']['icmp']['require_v4']   = nil
default['opennms']['properties']['icmp']['require_v6']   = nil
# SNMP
default['opennms']['properties']['snmp']['strategy_class']             = nil
default['opennms']['properties']['snmp']['smisyntaxes']                = "opennms-snmp4j-smisyntaxes.properties"
default['opennms']['properties']['snmp']['forward_runtime_exceptions'] = false
default['opennms']['properties']['snmp']['log_factory']                = "org.snmp4j.log.Log4jLogFactory"
default['opennms']['properties']['snmp']['allow_64bit_ipaddress']      = true
# Data collection
default['opennms']['properties']['dc']['store_by_group']          = false
default['opennms']['properties']['dc']['store_by_foreign_source'] = false
default['opennms']['properties']['dc']['rrd_base_dir']            = "#{default['opennms']['conf']['home']}/share/rrd"
default['opennms']['properties']['dc']['rrd_dc_dir']              = "/snmp/"
default['opennms']['properties']['dc']['rrd_binary']              = "/usr/bin/rrdtool"
default['opennms']['properties']['dc']['decimal_format']          = nil
default['opennms']['properties']['dc']['reload_check_interval']   = nil
default['opennms']['properties']['dc']['instrumentation_class']   = nil
default['opennms']['properties']['dc']['enable_check_file_mod']   = nil
default['opennms']['properties']['dc']['force_rescan']            = nil
default['opennms']['properties']['dc']['instance_limiting']       = nil
# Remote
default['opennms']['properties']['remote']['rmi_server_hostname']      = nil
default['opennms']['properties']['remote']['exclude_service_monitors'] = "DHCP,NSClient,RadiusAuth,XMP"
default['opennms']['properties']['remote']['min_config_reload_int']    = nil
# Ticketing
default['opennms']['properties']['ticket']['servicelayer']  = "org.opennms.netmgt.ticketd.DefaultTicketerServiceLayer"
default['opennms']['properties']['ticket']['plugin']        = "org.opennms.netmgt.ticketd.NullTicketerPlugin"
default['opennms']['properties']['ticket']['enabled']       = nil
default['opennms']['properties']['ticket']['link_template'] = nil
# Misc
default['opennms']['properties']['misc']['layout_applications_vertically'] = false
default['opennms']['properties']['misc']['bin_dir']                        = "#{default['opennms']['conf']['home']}/bin"
default['opennms']['properties']['misc']['webapp_logs_dir']                = "#{default['opennms']['conf']['home']}/logs/webapp"
default['opennms']['properties']['misc']['headless']                       = true
default['opennms']['properties']['misc']['find_by_service_type_query']     = nil
default['opennms']['properties']['misc']['load_snmp_data_on_init']         = nil
default['opennms']['properties']['misc']['allow_html_fields']              = nil
# Reporting
default['opennms']['properties']['reporting']['template_dir']         = "#{default['opennms']['conf']['home']}/etc"
default['opennms']['properties']['reporting']['report_dir']           = "#{default['opennms']['conf']['home']}/share/reports"
default['opennms']['properties']['reporting']['report_logo']          = "#{default['opennms']['conf']['home']}/webapps/images/logo.gif"
default['opennms']['properties']['reporting']['ksc_graphs_per_line']  = 1
default['opennms']['properties']['reporting']['jasper_version']       = "3.7.6"
# Eventd IPC
default['opennms']['properties']['eventd']['proxy_host']     = nil
default['opennms']['properties']['eventd']['proxy_port']     = nil
default['opennms']['properties']['eventd']['proxy_timeout']  = nil
# RANCID
default['opennms']['properties']['rancid']['enabled']              = nil
default['opennms']['properties']['rancid']['only_rancid_adapter']  = nil
# RTC IPC
default['opennms']['properties']['rtc']['baseurl']   = "http://localhost:8980/opennms/rtc/post"
default['opennms']['properties']['rtc']['username']  = "rtc"
default['opennms']['properties']['rtc']['password']  = "rtc"
# MAP IPC
default['opennms']['properties']['map']['baseurl']   = "http://localhost:8980/opennms/map/post"
default['opennms']['properties']['map']['username']  = "map"
default['opennms']['properties']['map']['password']  = "map"
# JETTY
default['opennms']['properties']['jetty']['port']                   = 8980
default['opennms']['properties']['jetty']['ajp']                    = nil
default['opennms']['properties']['jetty']['host']                   = nil
default['opennms']['properties']['jetty']['max_form_content_size']  = nil
default['opennms']['properties']['jetty']['request_header_size']    = nil
default['opennms']['properties']['jetty']['max_form_keys']          = 2000
default['opennms']['properties']['jetty']['https_port']             = nil
default['opennms']['properties']['jetty']['https_host']             = nil
default['opennms']['properties']['jetty']['keystore']               = nil
default['opennms']['properties']['jetty']['ks_password']            = nil
default['opennms']['properties']['jetty']['key_password']           = nil
default['opennms']['properties']['jetty']['cert_alias']             = nil
default['opennms']['properties']['jetty']['exclude_cipher_suites']  = nil
default['opennms']['properties']['jetty']['https_baseurl']          = nil
# UI
default['opennms']['properties']['ui']['acls']                        = nil
default['opennms']['properties']['ui']['ack']                         = false
default['opennms']['properties']['ui']['show_count']                  = false
default['opennms']['properties']['ui']['show_outage_nodes']           = nil
default['opennms']['properties']['ui']['show_problem_nodes']          = nil
default['opennms']['properties']['ui']['outage_node_count']           = nil
default['opennms']['properties']['ui']['problem_node_count']          = nil
default['opennms']['properties']['ui']['show_node_status_bar']        = nil
default['opennms']['properties']['ui']['disable_login_success_event'] = nil
default['opennms']['properties']['ui']['center_url']                  = nil
# Asterisk AGI
default['opennms']['properties']['asterisk']['listen_address'] = nil
default['opennms']['properties']['asterisk']['listen_port']    = nil
default['opennms']['properties']['asterisk']['max_pool_size']  = nil
# Provisioning
default['opennms']['properties']['provisioning']['dns_server']                = "127.0.0.1"
default['opennms']['properties']['provisioning']['max_concurrent_xtn']        = nil
default['opennms']['properties']['provisioning']['enable_discovery']          = nil
default['opennms']['properties']['provisioning']['enable_deletions']          = nil
default['opennms']['properties']['provisioning']['schedule_existing_rescans'] = nil
default['opennms']['properties']['provisioning']['schedule_updated_rescans']  = nil
# SMS Gateway
default['opennms']['properties']['sms']['serial_ports']  = "/dev/ttyACM0:/dev/ttyACM1:/dev/ttyACM2:/dev/ttyACM3:/dev/ttyACM4:/dev/ttyACM5"
default['opennms']['properties']['sms']['polling']       = true
# Mapping / Geocoding
default['opennms']['properties']['geo']['map_type']       = "OpenLayers"
default['opennms']['properties']['geo']['api_key']        = ""
default['opennms']['properties']['geo']['geocoder_class'] = "org.opennms.features.poller.remote.gwt.server.geocoding.NullGeocoder"
default['opennms']['properties']['geo']['rate']           = 10
default['opennms']['properties']['geo']['referrer']       = "http://localhost/"
default['opennms']['properties']['geo']['min_quality']    = "ZIP"
default['opennms']['properties']['geo']['email']          = ""
default['opennms']['properties']['geo']['tile_url']       = "http://otile1.mqcdn.com/tiles/1.0.0/osm/${z}/${x}/${y}.png"


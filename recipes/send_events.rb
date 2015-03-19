# verious scripts that tell OpenNMS to update
# the in-memory representation of changed config
# files without full restarts of OpenNMS

reload_uei = 'uei.opennms.org/internal/reloadDaemonConfig'
onms_home = node['opennms']['conf']['home']
send_event = "#{onms_home}/bin/send-event.pl"

# things that support reloadDaemonConfig
reload_daemons = {
  'Ackd' => { 'subscribes' => "template[#{onms_home}/etc/ackd-configuration.xml]" },
  'Provisiond.MapProvisioningAdapter' => { 'subscribes' => "template[#{onms_home}/etc/mapsadapter-configuration.xml]" },
  'Notifd' => { 'subscribes' => "template[#{onms_home}/etc/notificationCommands.xml]" },
  'Provisiond' => { 'subscribes' => "template[#{onms_home}/etc/provisiond-configuration.xml]" },
  'Scriptd' => { 'subscribes' => "template[#{onms_home}/etc/scriptd-configuration.xml]" },
  'Provisiond.SnmpAssetProvisioningAdapter' => { 'subscribes' => "template[#{onms_home}/etc/snmp-asset-adapter-configuration.xml]" },
  'Statsd' => { 'subscribes' => "template[#{onms_home}/etc/statsd-configuration.xml]" },
  'Translator' => { 'subscribes' => "template[#{onms_home}/etc/translator-configuration.xml]" },
  'Threshd' => { 'subscribes' => "template[#{onms_home}/etc/threshd-configuration.xml]"},
  'Thresholds' => { 'configFile' => 'thresholds.xml', 'subscribes' => "template[#{onms_home}/etc/thresholds.xml]"},
  'Vacuumd' => { 'subscribes' => "template[#{onms_home}/etc/vacuumd-configuration.xml]" }
}
reload_daemons.each do |daemon, settings|
  name = daemon
  cmd = "#{send_event} -p 'daemonName #{daemon}' #{reload_uei}"
  if daemon == 'Thresholds'
    name = 'Threshd' 
    cmd = "#{send_event} -p 'daemonName #{daemon}' -p 'configFile #{settings['configFile']}' #{reload_uei}"
  end
  bash "restart_#{name}" do
    code cmd
    user 'root'
    cwd onms_home
    action :nothing
    subscribes :create, settings['subscribes'], :delayed
  end
end

specific_ueis = {
  'discovery-configuration.xml' => 'uei.opennms.org/internal/discoveryConfigChange',
  'model-importer.properties' => 'uei.opennms.org/internal/importer/reloadImport',
  'poll-outages.xml' => 'uei.opennms.org/internal/schedOutagesChanged',
  'snmp-config.xml' => 'uei.opennms.org/internal/configureSNMP',
  'syslogd-configuration.xml' => 'uei.opennms.org/internal/syslogdConfigChange',
}
specific_ueis.each do |file, uei|
  Chef::Log.debug("Making bash resource 'restart_#{file}'")
  bash "restart_#{file}" do
    code "#{onms_home}/bin/send-event.pl #{uei}"
    user 'root'
    cwd onms_home
    action :nothing
    subscribes :create, "template[#{onms_home}/etc/#{file}]", :delayed
  end
end

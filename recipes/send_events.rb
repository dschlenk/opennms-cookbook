# verious scripts that tell OpenNMS to update
# the in-memory representation of changed config
# files without full restarts of OpenNMS

reload_uei = 'uei.opennms.org/internal/reloadDaemonConfig'
onms_home = node['opennms']['conf']['home']
send_event = "#{onms_home}/bin/send-event.pl"

# things that support reloadDaemonConfig
reload_daemons = {
  'Ackd' => { 'template' => "ackd-configuration.xml]" },
  'Eventd' => { 'template' => "eventconf.xml]" },
  'Provisiond.MapProvisioningAdapter' => { 'template' => "mapsadapter-configuration.xml" },
  'Notifd' => { 'template' => "notificationCommands.xml" },
  'Provisiond' => { 'template' => "provisiond-configuration.xml" },
  'Scriptd' => { 'template' => "scriptd-configuration.xml]" },
  'Provisiond.SnmpAssetProvisioningAdapter' => { 'template' => "snmp-asset-adapter-configuration.xml" },
  'Statsd' => { 'template' => "statsd-configuration.xml" },
  'Translator' => { 'template' => "translator-configuration.xml" },
  'Threshd' => { 'template' => "threshd-configuration.xml"},
  'Thresholds' => { 'template' => "thresholds.xml"},
  'Vacuumd' => { 'template' => "vacuumd-configuration.xml" }
}
reload_daemons.each do |daemon, settings|
  params = ["daemonName #{daemon}"]
  cmd = "#{send_event} -p 'daemonName #{daemon}' #{reload_uei}"
  if daemon == 'Thresholds'
    params = ["daemonName Threshd", "configFile thresholds.xml"]
  end
  tm = nil
  file = "#{onms_home}/etc/#{settings['template']}"
  begin
    tm = resources(template: file)
  rescue
    Chef::Log.info("No template for #{settings['template']} found in run list.")
  end
  opennms_send_event "restart_#{daemon}" do
    parameters params
    action :nothing
    unless tm.nil?
      subscribes :create, settings['subscribes'], :delayed
    end
  end
end

specific_ueis = {
  'discovery-configuration.xml' => 'uei.opennms.org/internal/discoveryConfigChange',
  'model-importer.properties' => 'uei.opennms.org/internal/importer/reloadImport',
  'poll-outages.xml' => 'uei.opennms.org/internal/schedOutagesChanged',
  'snmp-config.xml' => 'uei.opennms.org/internal/configureSNMP',
  'syslogd-configuration.xml' => 'uei.opennms.org/internal/syslogdConfigChange'
}
specific_ueis.each do |file, u|
  Chef::Log.debug("Making send_event resource 'activate_#{file}'")
  tm = nil
  begin
    tm = resources(template: file)
  rescue
    Chef::Log.info("No template for file #{file} found in run list.")
  end
  opennms_send_event "activate_#{file}" do
    uei u
    action :nothing
    unless tm.nil?
      subscribes :create, resource, :delayed
    end
  end
end

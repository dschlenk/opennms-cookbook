onms_home = node[:opennms][:conf][:home]
onms_home ||= '/opt/opennms'

package "opennms-plugin-protocol-nsclient" do
  version "1.12.9-1"
  action "install"
end

template "#{onms_home}/etc/nsclient-datacollection-config.xml" do
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



onms_home = node[:opennms][:conf][:home]
onms_home ||= '/opt/opennms'

package "opennms-plugin-protocol-xml" do
  version node['opennms']['version']
  action "install"
end

template "#{onms_home}/etc/xml-datacollection-config.xml" do
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



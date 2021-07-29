# frozen_string_literal: true
# Copy the example keystore file in place
cookbook_file 'jetty.keystore' do
  path "#{node['opennms']['conf']['home']}/etc/jetty.keystore"
  owner 'root'
  group 'root'
  mode 00644
  action :create_if_missing
end

ver = node['opennms']['version']
m = ver.match(/(\d+)\..*/)
mv = m.captures[0].to_i
cookbook_file 'jetty.xml' do
  path '/opt/opennms/etc/jetty.xml'
  notifies :restart, 'service[opennms]'
  only_if { mv >= 26 }
end
cookbook_file 'jetty-25.xml' do
  path '/opt/opennms/etc/jetty.xml'
  notifies :restart, 'service[opennms]'
  not_if { mv >= 19 & mv < 26}
end
# see default attributes file for other configuration changes made to the web server

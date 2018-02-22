# frozen_string_literal: true
# Copy the example keystore file in place
cookbook_file 'jetty.keystore' do
  path "#{node['opennms']['conf']['home']}/etc/jetty.keystore"
  owner 'root'
  group 'root'
  mode 00644
  action :create_if_missing
end

cookbook_file 'jetty.xml' do
  path '/opt/opennms/etc/jetty.xml'
end
# see default attributes file for other configuration changes made to the web server

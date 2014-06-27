# Copy the example keystore file in place
cookbook_file 'jetty.keystore' do
  path "#{node['opennms']['conf']['home']}/etc/jetty.keystore"
  owner 'root'
  group 'root'
  mode 00644
  action :create_if_missing
end 

node.default['opennms']['properties']['jetty']['https_port'] = 443
node.default['opennms']['properties']['jetty']['https_host'] = '0.0.0.0'
node.default['opennms']['properties']['jetty']['keystore'] = "#{node['opennms']['conf']['home']}/etc/jetty.keystore"
node.default['opennms']['properties']['jetty']['ks_password'] = 'changeit'
node.default['opennms']['properties']['jetty']['key_password'] = 'changeit'
node.default['opennms']['properties']['jetty']['cert_alias'] = 'opennms-jetty-certificate'
node.default['opennms']['properties']['jetty']['ajp'] = 8009
node.default['opennms']['properties']['jetty']['ajp'] = 8009

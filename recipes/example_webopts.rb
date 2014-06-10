# Copy the example keystore file in place
file "#{node['opennms']['conf']['home']}/etc/jetty.keystore" do
  owner 'root'
  group 'root'
  mode 00644
  content ::File.open("#{node['opennms']['conf']['home']}/etc/examples/jetty.keystore").read
  action :create
end 

node.default['opennms']['properties']['jetty']['https_port'] = 443
node.default['opennms']['properties']['jetty']['https_host'] = '0.0.0.0'
node.default['opennms']['properties']['jetty']['keystore'] = "#{node['opennms']['conf']['home']}/etc/jetty.keystore"
node.default['opennms']['properties']['jetty']['ks_password'] = 'changeit'
node.default['opennms']['properties']['jetty']['key_password'] = 'changeit'
node.default['opennms']['properties']['jetty']['cert_alias'] = 'opennms-jetty-certificate'
node.default['opennms']['properties']['jetty']['ajp'] = 8009
node.default['opennms']['properties']['jetty']['ajp'] = 8009

canary = '/root/.upgrade-canary'
if !::File.exist?('/opt/opennms') || !::File.exist?(canary)
  Chef::Log.warn('canary does not exist; overriding')
  node.override['opennms']['repos']['vault'] = ['34.0.0']
  node.override['opennms']['version'] = '34.0.0'
  node.override['opennms']['stable'] = false
  file canary do
    action :touch
  end
end

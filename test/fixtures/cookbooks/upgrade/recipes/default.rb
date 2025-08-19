canary = '/root/.upgrade-canary'
if !::File.exist?('/opt/opennms') || !::File.exist?(canary)
  Chef::Log.warn('canary does not exist; overriding')
  node.override['opennms']['repos']['vault'] = ['33.6.0']
  node.override['opennms']['version'] = '33.6.0-1'
  node.override['opennms']['stable'] = false
  file canary do
    action :touch
  end
end

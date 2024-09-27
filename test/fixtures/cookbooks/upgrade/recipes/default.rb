canary = "/root/.upgrade-canary"
if !::File::exist?('/opt/opennms') || !::File::exist?(canary)
  Chef::Log.warn("canary does not exist; overriding")
  node.override['opennms']['repos']['vault'] = ['32.0.6']
  node.override['opennms']['version'] = '32.0.6-1' 
  node.override['opennms']['stable'] = false
  file canary do
    action :touch
  end
end

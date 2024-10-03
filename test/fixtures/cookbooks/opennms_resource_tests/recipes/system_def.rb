# frozen_string_literal: true
opennms_system_def 'Cisco Routers' do
  groups %w(mib2-tcp mib2-powerethernet)
  action :add
end
opennms_system_def 'Cisco ASA5510sy' do
  groups %w(cisco-pix cisco-memory)
  action :remove
end

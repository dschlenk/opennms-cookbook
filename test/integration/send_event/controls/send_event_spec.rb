# frozen_string_literal: true
control 'send_event' do
  describe send_event('uei.opennms.org/internal/reloadDaemonConfig', 1236) do
    it { should exist }
    its('parameters') { should include 'daemonName Threshd' }
    its('parameters') { should include 'configFile thresholds.xml' }
  end

  describe send_event('uei.opennms.org/internal/configureSNMP', 1236) do
    it { should exist }
  end
end

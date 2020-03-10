# frozen_string_literal: true
control 'poller_edit' do
  describe poller_service('ICMPBar7', 'bar') do
    it { should exist }
    its('class_name') { should eq 'org.opennms.netmgt.poller.monitors.SnmpMonitor' }
    its('interval') { should eq 600_000 }
    its('user_defined') { should eq true }
    its('status') { should eq 'off' }
    its('time_out') { should eq 5000 }
    # rubocop:disable Style/EmptyLiteral
    its('parameters') { should eq Hash.new }
    # rubocop:enable Style/EmptyLiteral
  end
end

# frozen_string_literal: true
control 'event_edit_forward' do
  #  Swaps static file 'event' matcher for the 'opennms_event' wrapper
  #  Fixes NilClass crash on 'forward' property checks during verification
  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded2') do
    it { should exist }
    its('forward') { should eq([{ 'info' => 'fwdInfo', 'state' => 'off', 'mechanism' => 'snmpudp' }]) }
  end
end

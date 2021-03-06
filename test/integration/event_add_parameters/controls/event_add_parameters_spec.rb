# frozen_string_literal: true
control 'event_add_parameters' do
  e = event('uei.opennms.org/cheftest/thresholdExceeded2', 'events/chef.events.xml', [{ 'mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1'] }, { 'mename' => 'generic', 'mevalue' => ['6'] }, { 'mename' => 'specific', 'mevalue' => ['2'] }])
  if e.parameters.nil?
    describe e do
      it { should exist }
    end
  elsif e.parameters[1].key? 'expand'
    # > 16 supports parameters
    describe e do
      it { should exist }
      its('parameters') { should eq([{ 'name' => 'param1', 'value' => 'paramValue1' }, { 'name' => 'param2', 'value' => 'paramValue2', 'expand' => true }]) }
    end
  else
    # except 17 didn't have the expand attribute
    describe e do
      it { should exist }
      its('parameters') { should eq([{ 'name' => 'param1', 'value' => 'paramValue1' }, { 'name' => 'param2', 'value' => 'paramValue2' }]) }
    end
  end
end

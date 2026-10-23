# frozen_string_literal: true

control 'uei.opennms.org/cheftest/thresholdExceeded configurations' do
  title 'OpenNMS Live Event REST API'

  # Base Element Checks
  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded', 'events/chef.events.xml') do
    it { should exist }
    its('eventLabel')              { should eq 'Chef defined event: thresholdExceeded' }
    its('descr')                   { should include 'A threshold defined by a chef recipe has been exceeded.' }
    its('logmsg.content')          { should eq 'A threshold has been exceeded.' }
    its('logmsg.dest')             { should eq 'logndisplay' }
    its('logmsg.notify')           { should be true }
    its('severity')                { should eq 'Minor' }
    its('alarmData.reductionKey')  { should eq '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%' }
    its('alarmData.alarmType')     { should eq 1 }
    its('alarmData.autoClean')     { should be false }
  end

  # Script Modifiers Validation Block
  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded2-script', 'events/chef.events.xml') do
    it { should exist }
    its('eventLabel')              { should eq 'Chef defined event: thresholdExceeded' }
    its('descr')                   { should include 'A threshold defined by a chef recipe has been exceeded.' }
    its('logmsg.content')          { should eq 'A threshold has been exceeded.' }
    its('logmsg.dest')             { should eq 'logndisplay' }
    its('logmsg.notify')           { should be true }
    its('severity')                { should eq 'Minor' }
    its('operinstruct')            { should eq 'the operinstruct' }
    its('mouseovertext')           { should eq 'mouseOverText' }
    its('tticket.info')            { should eq 'tticketInfo' }
    its('tticket.state')           { should eq 'off' }

    it 'contains the required mask elements' do
      mask_elements = subject.event_data.dig('mask', 'maskelement') || []
      expect(mask_elements).to include(
                                 hash_including('mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1']),
                                 hash_including('mename' => 'generic', 'mevalue' => ['6']),
                                 hash_including('mename' => 'specific', 'mevalue' => ['2'])
                               )
    end

    it 'contains the required autoaction attributes' do
      expect(subject.event_data['autoaction']).to include(hash_including('action' => 'someaction', 'state' => 'off'))
    end

    it 'contains the required varbindsdecode values' do
      expect(subject.event_data['varbindsdecode']).to include(hash_including('parmid' => 'theParmId'))
    end

    it 'contains the required forward configuration payloads' do
      expect(subject.event_data['forward']).to include(hash_including('info' => 'fwdInfo', 'state' => 'off', 'mechanism' => 'snmptcp'))
    end

    it 'contains the required script properties' do
      expect(subject.event_data['script']).to include(hash_including('name' => 'anScript', 'language' => 'groovy'))
    end
  end

  # Structural Top Check
  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded3', 'events/chef.events.xml') do
    it { should exist }
    its('eventLabel')              { should eq 'Chef defined event: thresholdExceeded3' }
    its('descr')                   { should include 'A threshold defined by a chef recipe has been exceeded3.' }
    its('logmsg.content')          { should eq 'A threshold has been exceeded3.' }
    its('logmsg.dest')             { should eq 'logndisplay' }
    its('logmsg.notify')           { should be true }
    its('severity')                { should eq 'Minor' }
  end
end

control 'uei.opennms.org/cheftest/thresholdExceeded 4 and 5 configurations' do
  title 'OpenNMS Live Event REST API - chef.events'

  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded4-complex', 'events/chef.events.xml') do
    it { should exist }
    its('eventLabel')              { should eq 'Chef defined event: thresholdExceeded4' }
    its('descr')                   { should include 'A threshold defined by a chef recipe has been exceeded4.' }
    its('logmsg.content')          { should eq 'A threshold has been exceeded4.' }
    its('logmsg.dest')             { should eq 'logndisplay' }
    its('logmsg.notify')           { should be true }
    its('severity') { should eq 'Minor' }
    its('operinstruct')            { should eq 'the operinstruct' }
    its('mouseovertext')           { should eq 'mouseOverText' }
    its('tticket.info')            { should eq 'tticketInfo' }
    its('tticket.state')           { should eq 'off' }
    its('alarmData.reductionKey')  { should eq '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%' }
    its('alarmData.alarmType')     { should eq 1 }
    its('alarmData.autoClean')     { should be false }

    it 'contains the required complex structures matching attributes' do
      expect(subject.event_data['autoaction']).to include(hash_including('action' => 'someaction', 'state' => 'off'))
      expect(subject.event_data['varbindsdecode']).to include(hash_including('parmid' => 'theParmId'))
      expect(subject.event_data['forward']).to include(hash_including('info' => 'fwdInfo', 'state' => 'off', 'mechanism' => 'snmptcp'))
      expect(subject.event_data['script']).to include(hash_including('name' => 'anScript', 'language' => 'groovy'))
    end
  end

  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded5-arrays', 'events/chef.events.xml') do
    it { should exist }
    its('eventLabel')              { should eq 'Chef defined event: thresholdExceeded5' }
    its('descr')                   { should include 'A threshold defined by a chef recipe has been exceeded4.' }
    its('logmsg.content')          { should eq 'A threshold has been exceeded4.' }
    its('logmsg.dest')             { should eq 'logndisplay' }
    its('logmsg.notify')           { should be true }
    its('severity')                { should eq 'Minor' }
    its('alarmData.reductionKey')  { should eq '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%' }

    it 'contains the required mask elements including vbnumber and vbvalue arrays' do
      mask_elements = subject.event_data.dig('mask', 'maskelement') || []
      varbind_elements = subject.event_data.dig('mask', 'varbind') || []

      expect(mask_elements).to include(
                                 hash_including('mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1']),
                                 hash_including('mename' => 'generic', 'mevalue' => ['6']),
                                 hash_including('mename' => 'specific', 'mevalue' => ['2'])
                               )
      expect(varbind_elements).to include(
                                    hash_including('vbnumber' => '1', 'vbvalue' => %w(1 2 3))
                                  )
    end
  end
end

control 'uei.opennms.org/anUeiForANewThingInANewFile absence verification' do
  title 'OpenNMS Live Event REST API - chef2.events'

  describe opennms_event('uei.opennms.org/anUeiForANewThingInANewFile-absent', 'events/chef2.events.xml') do
    it { should_not exist }
  end
end

control 'OpenNMS Live Event REST API - chef3.events and chef4.events position validations' do
  title 'Position isolated validations'

  describe opennms_event('uei.opennms.org/anUeiForANewThingInANewFileWithPositionTop-isolated', 'events/chef3.events.xml') do
    it { should exist }
    its('severity')                { should eq 'Minor' }
    its('alarmData.reductionKey')  { should eq '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%' }
    its('alarmData.alarmType')     { should eq 1 }
    its('alarmData.autoClean')     { should be false }
  end

  describe opennms_event('uei.opennms.org/fillerForANewThingInANewFile1-isolated', 'events/chef4.events.xml') do
    it { should exist }
  end

  describe opennms_event('uei.opennms.org/fillerForANewThingInANewFile2-isolated', 'events/chef4.events.xml') do
    it { should exist }
  end

  describe opennms_event('uei.opennms.org/eventTopFileTop-isolated', 'events/chef4.events.xml') do
    it { should exist }
  end

  describe opennms_event('uei.opennms.org/eventBottomFileTop-isolated', 'events/chef4.events.xml') do
    it { should exist }
  end
end

control 'OpenNMS Live Event REST API - chef5.events collection group' do
  title 'chef5.events validations'

  describe opennms_event('uei.opennms.org/collectionGroupTest-isolated', 'events/chef5.events.xml') do
    it { should exist }
    its('severity') { should eq 'Indeterminate' }

    it 'contains the correct collectionGroup attributes' do
      expect(subject.event_data['collectionGroup']).to include(
                                                         hash_including(
                                                           'name' => 'nodeGroup',
                                                           'resourceType' => 'nodeSnmp',
                                                           'instance' => 'instanceParmName'
                                                         )
                                                       )
    end
  end
end

control 'OpenNMS Live Event REST API - chef6.events parameters, autoack, and filters' do
  title 'chef6.events structural validations'

  describe opennms_event('uei.opennms.org/parametersTest-isolated', 'events/chef6.events.xml') do
    it { should exist }
    its('severity') { should eq 'Critical' }
    it 'contains the requested nested parameter mappings' do
      expect(subject.event_data['parameter']).to include(
                                                   hash_including(
                                                     'name' => 'paramName',
                                                     'value' => 'someString',
                                                     'expand' => true
                                                   )
                                                 )
    end
  end

  describe opennms_event('uei.opennms.org/autoackTest-isolated', 'events/chef6.events.xml') do
    it { should exist }
    its('severity') { should eq 'Minor' }
    its('autoacknowledge.info') { should eq 'please do not wake me up when the computer breaks' }
    its('autoacknowledge.state') { should eq 'off' }
  end

  describe opennms_event('uei.opennms.org/filters-isolated', 'events/chef6.events.xml') do
    it { should exist }
    its('severity') { should eq 'Major' }
    it 'contains the correct eventFilter configurations matching the recipe values' do
      filters = subject.event_data['filter'] || subject.event_data['filters'] || []
      expect(filters).to include(
                           hash_including(
                             'eventparm' => 'one',
                             'pattern' => '^one_and_two_matching_pattern$',
                             'replacement' => 'MATCHED_AND_REPLACED'
                           )
                         )
    end
  end
end

control 'OpenNMS Live Event REST API - chef.events file actions' do
  title 'chef.events file creation state validations'

  describe opennms_event('create_if_missing-isolated', 'events/chef.events.xml') do
    it { should exist }
    # Verifies that create_if_missing successfully populated pristine properties
    its('eventLabel')              { should eq 'Chef defined event: createifmissing' }
    its('severity')                { should eq 'Minor' }
  end

  describe opennms_event('create_if_missing-isolated', 'events/chef.events.xml') do
    # Verifies that the second no-op call left the first entry pristine and untouched
    its('eventLabel')              { should_not eq 'Chef defined event: noopcreateifmissing' }
  end
end

control 'OpenNMS Live Event REST API - Dynamic Outage Loops' do
  title 'Pollerd certificate loops validation'
  [443, 8443].each do |_port|
    [60, 30].each do |_days|
      describe opennms_event('uei.opennms.org/nodes/nodeLostService', 'events/opennms.pollerd.events.xml') do
        it { should exist }
        its('eventLabel') { should eq 'OpenNMS-defined node event: nodeLostService' }
        its('logmsg.dest') { should eq 'logndisplay' }
      end
    end
  end
end

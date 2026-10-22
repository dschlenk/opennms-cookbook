# frozen_string_literal: true

control 'uei.opennms.org/cheftest/thresholdExceeded configurations' do
  title 'OpenNMS Live Event REST API'

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

  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded2', 'events/chef.events.xml') do
    it { should exist }
    its('eventLabel')              { should eq 'Chef defined event: thresholdExceeded' }
    its('descr')                   { should include 'A threshold defined by a chef recipe has been exceeded.' }
    its('logmsg.content')          { should eq 'A threshold has been exceeded.' }
    its('logmsg.dest')             { should eq 'logndisplay' }
    its('logmsg.notify')           { should be true }
    its('severity')                { should eq 'Minor' }
    its('operinstruct')            { should eq 'the operinstruct' }
    its('mouseovertext')           { should eq 'mouseOverText' }
    its('tticket.content')         { should eq 'tticketInfo' }
    its('tticket.state')           { should eq 'off' }

    it 'contains the required mask elements' do
      mask_elements = subject.event_data.dig('mask', 'maskelement') || []
      expect(mask_elements).to include(
                                 hash_including('mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1']),
                                 hash_including('mename' => 'generic', 'mevalue' => ['6']),
                                 hash_including('mename' => 'specific', 'mevalue' => ['2'])
                               )
    end

    it 'contains the required autoaction' do
      expect(subject.event_data['autoaction']).to include(hash_including('content' => 'someaction', 'state' => 'off'))
    end

    it 'contains the required varbindsdecode' do
      expect(subject.event_data['varbindsdecode']).to include(hash_including('parmid' => 'theParmId'))
    end

    it 'contains the required forward payload' do
      expect(subject.event_data['forward']).to include(hash_including('content' => 'fwdInfo', 'state' => 'off', 'mechanism' => 'snmptcp'))
    end

    it 'contains the required script payload' do
      expect(subject.event_data['script']).to include(hash_including('content' => 'anScript', 'language' => 'groovy'))
    end
  end

  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded3', 'events/chef.events.xml') do
    it { should exist }
    its('eventLabel')              { should eq 'Chef defined event: thresholdExceeded3' }
    its('descr')                   { should include 'A threshold defined by a chef recipe has been exceeded3.' }
    its('logmsg.content')          { should eq 'A threshold has been exceeded3.' }
    its('logmsg.dest')             { should eq 'logndisplay' }
    its('logmsg.notify')           { should be true }
    its('severity')                { should eq 'Minor' }
    its('operinstruct')            { should eq 'the operinstruct' }
    its('mouseovertext')           { should eq 'mouseOverText' }
  end
end

control 'uei.opennms.org/cheftest/thresholdExceeded 4 and 5 configurations' do
  title 'OpenNMS Live Event REST API - chef.events'

  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded4', 'events/chef.events.xml') do
    it { should exist }
    its('eventLabel')              { should eq 'Chef defined event: thresholdExceeded4' }
    its('descr')                   { should include 'A threshold defined by a chef recipe has been exceeded4.' }
    its('logmsg.content')          { should eq 'A threshold has been exceeded4.' }
    its('logmsg.dest')             { should eq 'logndisplay' }
    its('logmsg.notify')           { should be true }
    its('severity')                { should eq 'Minor' }
    its('operinstruct')            { should eq 'the operinstruct' }
    its('mouseovertext')           { should eq 'mouseOverText' }
    its('tticket.content')         { should eq 'tticketInfo' }
    its('tticket.state')           { should eq 'off' }
    its('alarmData.reductionKey')  { should eq '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%' }
    its('alarmData.alarmType')     { should eq 1 }
    its('alarmData.autoClean')     { should be false }

    it 'contains the required mask elements' do
      mask_elements = subject.event_data.dig('mask', 'maskelement') || []
      expect(mask_elements).to include(
                                 hash_including('mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1']),
                                 hash_including('mename' => 'generic', 'mevalue' => ['6']),
                                 hash_including('mename' => 'specific', 'mevalue' => ['2'])
                               )
    end

    it 'contains the required complex structures' do
      expect(subject.event_data['autoaction']).to include(hash_including('content' => 'someaction', 'state' => 'off'))
      expect(subject.event_data['varbindsdecode']).to include(hash_including('parmid' => 'theParmId'))
      expect(subject.event_data['forward']).to include(hash_including('content' => 'fwdInfo', 'state' => 'off', 'mechanism' => 'snmptcp'))
      expect(subject.event_data['script']).to include(hash_including('content' => 'anScript', 'language' => 'groovy'))
    end
  end

  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded5', 'events/chef.events.xml') do
    it { should exist }
    its('eventLabel')              { should eq 'Chef defined event: thresholdExceeded5' }
    its('descr')                   { should include 'A threshold defined by a chef recipe has been exceeded4.' }
    its('logmsg.content')          { should eq 'A threshold has been exceeded4.' }
    its('logmsg.dest')             { should eq 'logndisplay' }
    its('logmsg.notify')           { should be true }
    its('severity')                { should eq 'Minor' }
    its('operinstruct')            { should eq 'the operinstruct' }
    its('mouseovertext')           { should eq 'mouseOverText' }
    its('tticket.content')         { should eq 'tticketInfo' }
    its('tticket.state')           { should eq 'off' }
    its('alarmData.reductionKey')  { should eq '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%' }
    its('alarmData.alarmType')     { should eq 1 }
    its('alarmData.autoClean')     { should be false }

    it 'contains the required mask elements including vbnumber and vbvalue arrays' do
      mask_elements = subject.event_data.dig('mask', 'maskelement') || []
      expect(mask_elements).to include(
                                 hash_including('mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1']),
                                 hash_including('mename' => 'generic', 'mevalue' => ['6']),
                                 hash_including('mename' => 'specific', 'mevalue' => ['2']),
                                 hash_including('vbnumber' => '1', 'vbvalue' => %w(1 2 3))
                               )
    end

    it 'contains the required complex structures' do
      expect(subject.event_data['autoaction']).to include(hash_including('content' => 'someaction', 'state' => 'off'))
      expect(subject.event_data['varbindsdecode']).to include(hash_including('parmid' => 'theParmId'))
      expect(subject.event_data['forward']).to include(hash_including('content' => 'fwdInfo', 'state' => 'off', 'mechanism' => 'snmptcp'))
      expect(subject.event_data['script']).to include(hash_including('content' => 'anScript', 'language' => 'groovy'))
    end
  end
end

control 'uei.opennms.org/anUeiForANewThingInANewFile absence verification' do
  title 'OpenNMS Live Event REST API - chef2.events'

  describe opennms_event('uei.opennms.org/anUeiForANewThingInANewFile', 'events/chef2.events.xml') do
    it { should_not exist }
  end
end

control 'OpenNMS Live Event REST API - chef3.events' do
  title 'chef3.events validation'

  describe opennms_event('uei.opennms.org/anUeiForANewThingInANewFileWithPositionTop', 'events/chef3.events.xml') do
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
end

control 'OpenNMS Live Event REST API - chef4.events' do
  title 'chef4.events validation'

  describe opennms_event('uei.opennms.org/fillerForANewThingInANewFile1', 'events/chef4.events.xml') do
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
end

control 'OpenNMS Live Event REST API - chef4.events extensions' do
  title 'chef4.events validations'

  describe opennms_event('uei.opennms.org/fillerForANewThingInANewFile2', 'events/chef4.events.xml') do
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

  describe opennms_event('uei.opennms.org/eventTopFileTop', 'events/chef4.events.xml') do
    it { should exist }
    its('eventLabel')              { should eq 'Chef defined event: thresholdExceeded' }
    its('descr')                   { should include 'A threshold defined by a chef recipe has been exceeded.' }
    its('logmsg.content')          { should eq 'A threshold has been exceeded.' }
    its('logmsg.dest')             { should eq 'logndisplay' }
    its('logmsg.notify')           { should be true }
    its('severity')                { should eq 'Minor' }
    its('alarmData.reductionKey')  { should eq '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%' }
  end

  describe opennms_event('uei.opennms.org/eventBottomFileTop', 'events/chef4.events.xml') do
    it { should exist }
    its('eventLabel')              { should eq 'Chef defined event: thresholdExceeded' }
    its('descr')                   { should include 'A threshold defined by a chef recipe has been exceeded.' }
    its('logmsg.content')          { should eq 'A threshold has been exceeded.' }
    its('logmsg.dest')             { should eq 'logndisplay' }
    its('logmsg.notify')           { should be true }
    its('severity')                { should eq 'Minor' }
    its('alarmData.reductionKey')  { should eq '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%' }
  end
end

control 'OpenNMS Live Event REST API - chef5.events collection group' do
  title 'chef5.events validations'

  describe opennms_event('uei.opennms.org/collectionGroupTest', 'events/chef5.events.xml') do
    it { should exist }
    its('eventLabel')              { should eq 'Chef defined event: thresholdExceeded' }
    its('descr')                   { should include 'collection group test.' }
    its('logmsg.content')          { should eq 'A collection group test.' }
    its('logmsg.dest')             { should eq 'logndisplay' }
    its('logmsg.notify')           { should be true }
    its('severity')                { should eq 'Indeterminate' }
    it 'contains the correct collectionGroup attributes' do
      expect(subject.event_data['collectionGroup']).to include(
                                                         hash_including(
                                                           'name' => 'nodeGroup',
                                                           'resourceType' => 'nodeSnmp',
                                                           'instance' => 'instanceParmName'
                                                         )
                                                       )
    end
    it 'validates nested metric mappings inside the collection group' do
      group = (subject.event_data['collectionGroup'] || []).find { |g| g['name'] == 'nodeGroup' }
      expect(group).not_to be_nil
      expect(group['collections']).to include(
                                        hash_including(
                                          'name' => 'TIME',
                                          'type' => 'counter',
                                          'paramValues' => hash_including('primary' => 1, 'secondary' => 2)
                                        )
                                      )
      expect(group.dig('rrd', 'step')).to eq 60
      expect(group.dig('rrd', 'heartbeat')).to eq 120
      expect(group.dig('rrd', 'rra')).to include('RRA:AVERAGE:0.5:1:8928')
    end
  end
end

control 'OpenNMS Live Event REST API - chef6.events parameters' do
  title 'chef6.events validations'

  describe opennms_event('uei.opennms.org/parametersTest', 'events/chef6.events.xml') do
    it { should exist }
    its('eventLabel')              { should eq 'Chef defined event: parametersTest' }
    its('descr')                   { should include 'parameters.' }
    # FIXED: Removed stray object constant mapping typo lines from compilation block
    its('logmsg.content')          { should eq 'parameters test.' }
    its('logmsg.dest')             { should eq 'logndisplay' }
    its('logmsg.notify')           { should be true }
    its('severity')                { should eq 'Critical' }
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
end

control 'OpenNMS Live Event REST API - chef6.events extensions' do
  title 'chef6.events structural validations'

  describe opennms_event('uei.opennms.org/operactionTest', 'events/chef6.events.xml') do
    it { should exist }
    its('eventLabel')              { should eq 'Chef defined event: operactionTest' }
    its('descr')                   { should include 'operactionTest.' }
    its('logmsg.content')          { should eq 'operactionTest test.' }
    its('logmsg.dest')             { should eq 'logndisplay' }
    its('logmsg.notify')           { should be true }
    its('severity')                { should eq 'Warning' }
    it 'contains the correct operaction configurations' do
      expect(subject.event_data['operaction']).to include(
                                                    hash_including(
                                                      'content' => 'string',
                                                      'state' => 'off',
                                                      'menutext' => 'help me'
                                                    )
                                                  )
    end
  end

  describe opennms_event('uei.opennms.org/autoackTest', 'events/chef6.events.xml') do
    it { should exist }
    its('eventLabel')              { should eq 'Chef defined event: autoackTest' }
    its('descr')                   { should include 'autoackTest.' }
    its('logmsg.content')          { should eq 'autoackTest test.' }
    its('logmsg.dest')             { should eq 'logndisplay' }
    its('logmsg.notify')           { should be true }
    its('severity')                { should eq 'Minor' }
    its('autoacknowledge.content') { should eq 'please do not wake me up when the computer breaks' }
    its('autoacknowledge.state')   { should eq 'off' }
  end

  describe opennms_event('uei.opennms.org/filters', 'events/chef6.events.xml') do
    it { should exist }
    its('eventLabel')              { should eq 'Chef defined event: filters' }
    its('descr')                   { should include 'filters.' }
    its('logmsg.content')          { should eq 'filters test.' }
    its('logmsg.dest')             { should eq 'logndisplay' }
    its('logmsg.notify')           { should be true }
    its('severity')                { should eq 'Major' }
    it 'contains the correct eventFilter configurations' do
      filters = subject.event_data['filter'] || subject.event_data['filters'] || subject.event_data['eventFilter'] || []
      expect(filters).to include(
                           hash_including(
                             'eventparm' => 'one',
                             'pattern' => '/^one&two{;t|hree}$/',
                             'replacement' => 'REPLACED'
                           )
                         )
    end
  end
  only_if('NMS-19814 is resolved') do
    false
  end
end

control 'OpenNMS Live Event REST API - chef.events file actions' do
  title 'chef.events file creation state validations'

  describe opennms_event('create_if_missing', 'events/chef.events.xml') do
    it { should exist }
    its('eventLabel')              { should eq 'Chef defined event: createifmissing' }
    its('descr')                   { should include 'Trying to create a file if its missing.' }
    its('logmsg.content')          { should eq 'creating file if its missing.' }
    its('logmsg.dest')             { should eq 'logndisplay' }
    its('logmsg.notify')           { should be true }
    its('severity')                { should eq 'Minor' }
  end

  describe opennms_event('noop_create_if_missing', 'events/chef.events.xml') do
    it { should_not exist }
  end
end

# frozen_string_literal: true

control 'uei.opennms.org/cheftest/thresholdExceeded configurations' do
  title 'OpenNMS Live Event REST API'

  events_data = opennms_event_api.fetch_live_eventconf_json('chef.events')
  events_list = events_data['events'] || []

  describe opennms_event_api.fetch_live_eventconf('chef.events') do
    its('exit_status') { should eq 0 }
  end

  describe 'Event uei.opennms.org/cheftest/thresholdExceeded' do
    subject { events_list.find { |e| e['uei'] == 'uei.opennms.org/cheftest/thresholdExceeded' } }

    it { should_not be_nil }
    its(['eventLabel']) { should eq 'Chef defined event: thresholdExceeded' }
    its(['descr']) { should include 'A threshold defined by a chef recipe has been exceeded.' }
    its(%w(logmsg content)) { should eq 'A threshold has been exceeded.' }
    its(%w(logmsg dest)) { should eq 'logndisplay' }
    its(%w(logmsg notify)) { should be true }
    its(['severity']) { should eq 'Minor' }
    its(%w(alarmData reductionKey)) { should eq '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%' }
    its(%w(alarmData alarmType)) { should eq 1 }
    its(%w(alarmData autoClean)) { should be false }
  end

  describe 'Event uei.opennms.org/cheftest/thresholdExceeded2' do
    subject { events_list.find { |e| e['uei'] == 'uei.opennms.org/cheftest/thresholdExceeded2' } }

    it { should_not be_nil }
    its(['eventLabel']) { should eq 'Chef defined event: thresholdExceeded' }
    its(['descr']) { should include 'A threshold defined by a chef recipe has been exceeded.' }
    its(%w(logmsg content)) { should eq 'A threshold has been exceeded.' }
    its(%w(logmsg dest)) { should eq 'logndisplay' }
    its(%w(logmsg notify)) { should be true }
    its(['severity']) { should eq 'Minor' }
    its(['operinstruct']) { should eq 'the operinstruct' }
    its(['mouseovertext']) { should eq 'mouseOverText' }
    its(%w(tticket content)) { should eq 'tticketInfo' }
    its(%w(tticket state)) { should eq 'off' }

    it 'contains the required mask elements' do
      mask_elements = subject.dig('mask', 'maskelement') || []
      expect(mask_elements).to include(
                                 hash_including('mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1']),
                                 hash_including('mename' => 'generic', 'mevalue' => ['6']),
                                 hash_including('mename' => 'specific', 'mevalue' => ['2'])
                               )
    end

    it 'contains the required autoaction' do
      expect(subject['autoaction']).to include(hash_including('content' => 'someaction', 'state' => 'off'))
    end

    it 'contains the required varbindsdecode' do
      expect(subject['varbindsdecode']).to include(hash_including('parmid' => 'theParmId'))
    end

    it 'contains the required forward payload' do
      expect(subject['forward']).to include(hash_including('content' => 'fwdInfo', 'state' => 'off', 'mechanism' => 'snmptcp'))
    end

    it 'contains the required script payload' do
      expect(subject['script']).to include(hash_including('content' => 'anScript', 'language' => 'groovy'))
    end
  end

  describe 'Event uei.opennms.org/cheftest/thresholdExceeded3' do
    subject { events_list.find { |e| e['uei'] == 'uei.opennms.org/cheftest/thresholdExceeded3' } }

    it { should_not be_nil }
    its(['eventLabel']) { should eq 'Chef defined event: thresholdExceeded3' }
    its(['descr']) { should include 'A threshold defined by a chef recipe has been exceeded3.' }
    its(%w(logmsg content)) { should eq 'A threshold has been exceeded3.' }
    its(%w(logmsg dest)) { should eq 'logndisplay' }
    its(%w(logmsg notify)) { should be true }
    its(['severity']) { should eq 'Minor' }
    its(['operinstruct']) { should eq 'the operinstruct' }
    its(['mouseovertext']) { should eq 'mouseOverText' }
  end
end

control 'uei.opennms.org/cheftest/thresholdExceeded 4 and 5 configurations' do
  title 'OpenNMS Live Event REST API - chef.events'

  events_data = opennms_event_api.fetch_live_eventconf_json('chef.events')
  events_list = events_data['events'] || []

  describe 'Event uei.opennms.org/cheftest/thresholdExceeded4' do
    subject { events_list.find { |e| e['uei'] == 'uei.opennms.org/cheftest/thresholdExceeded4' } }

    it { should_not be_nil }
    its(['eventLabel']) { should eq 'Chef defined event: thresholdExceeded4' }
    its(['descr']) { should include 'A threshold defined by a chef recipe has been exceeded4.' }
    its(%w(logmsg content)) { should eq 'A threshold has been exceeded4.' }
    its(%w(logmsg dest)) { should eq 'logndisplay' }
    its(%w(logmsg notify)) { should be true }
    its(['severity']) { should eq 'Minor' }
    its(['operinstruct']) { should eq 'the operinstruct' }
    its(['mouseovertext']) { should eq 'mouseOverText' }
    its(%w(tticket content)) { should eq 'tticketInfo' }
    its(%w(tticket state)) { should eq 'off' }
    its(%w(alarmData reductionKey)) { should eq '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%' }
    its(%w(alarmData alarmType)) { should eq 1 }
    its(%w(alarmData autoClean)) { should be false }

    it 'contains the required mask elements' do
      mask_elements = subject.dig('mask', 'maskelement') || []
      expect(mask_elements).to include(
                                 hash_including('mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1']),
                                 hash_including('mename' => 'generic', 'mevalue' => ['6']),
                                 hash_including('mename' => 'specific', 'mevalue' => ['2'])
                               )
    end

    it 'contains the required complex structures' do
      expect(subject['autoaction']).to include(hash_including('content' => 'someaction', 'state' => 'off'))
      expect(subject['varbindsdecode']).to include(hash_including('parmid' => 'theParmId'))
      expect(subject['forward']).to include(hash_including('content' => 'fwdInfo', 'state' => 'off', 'mechanism' => 'snmptcp'))
      expect(subject['script']).to include(hash_including('content' => 'anScript', 'language' => 'groovy'))
    end
  end

  describe 'Event uei.opennms.org/cheftest/thresholdExceeded5' do
    subject { events_list.find { |e| e['uei'] == 'uei.opennms.org/cheftest/thresholdExceeded5' } }

    it { should_not be_nil }
    its(['eventLabel']) { should eq 'Chef defined event: thresholdExceeded5' }
    its(['descr']) { should include 'A threshold defined by a chef recipe has been exceeded4.' }
    its(%w(logmsg content)) { should eq 'A threshold has been exceeded4.' }
    its(%w(logmsg dest)) { should eq 'logndisplay' }
    its(%w(logmsg notify)) { should be true }
    its(['severity']) { should eq 'Minor' }
    its(['operinstruct']) { should eq 'the operinstruct' }
    its(['mouseovertext']) { should eq 'mouseOverText' }
    its(%w(tticket content)) { should eq 'tticketInfo' }
    its(%w(tticket state)) { should eq 'off' }
    its(%w(alarmData reductionKey)) { should eq '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%' }
    its(%w(alarmData alarmType)) { should eq 1 }
    its(%w(alarmData autoClean)) { should be false }

    it 'contains the required mask elements including vbnumber and vbvalue arrays' do
      mask_elements = subject.dig('mask', 'maskelement') || []
      expect(mask_elements).to include(
                                 hash_including('mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1']),
                                 hash_including('mename' => 'generic', 'mevalue' => ['6']),
                                 hash_including('mename' => 'specific', 'mevalue' => ['2']),
                                 hash_including('vbnumber' => '1', 'vbvalue' => %w(1 2 3))
                               )
    end

    it 'contains the required complex structures' do
      expect(subject['autoaction']).to include(hash_including('content' => 'someaction', 'state' => 'off'))
      expect(subject['varbindsdecode']).to include(hash_including('parmid' => 'theParmId'))
      expect(subject['forward']).to include(hash_including('content' => 'fwdInfo', 'state' => 'off', 'mechanism' => 'snmptcp'))
      expect(subject['script']).to include(hash_including('content' => 'anScript', 'language' => 'groovy'))
    end
  end
end

control 'uei.opennms.org/anUeiForANewThingInANewFile absence verification' do
  title 'OpenNMS Live Event REST API - chef2.events'

  events_data = opennms_event_api.fetch_live_eventconf_json('chef2.events')
  events_list = events_data['events'] || []

  describe 'Event uei.opennms.org/anUeiForANewThingInANewFile' do
    subject { events_list.find { |e| e['uei'] == 'uei.opennms.org/anUeiForANewThingInANewFile' } }

    it { should be_nil }
  end
end

control 'OpenNMS Live Event REST API - chef3.events' do
  title 'chef3.events validation'

  events_data = opennms_event_api.fetch_live_eventconf_json('chef3.events')
  events_list = events_data['events'] || []

  describe opennms_event_api.fetch_live_eventconf('chef3.events') do
    its('exit_status') { should eq 0 }
  end

  describe 'chef3.events global profile data' do
    subject { events_data }

    its(['position']) { should eq 26 }
  end

  describe 'Event uei.opennms.org/anUeiForANewThingInANewFileWithPositionTop' do
    subject { events_list.find { |e| e['uei'] == 'uei.opennms.org/anUeiForANewThingInANewFileWithPositionTop' } }

    it { should_not be_nil }
    its(['eventLabel']) { should eq 'Chef defined event: thresholdExceeded' }
    its(['descr']) { should include 'A threshold defined by a chef recipe has been exceeded.' }
    its(%w(logmsg content)) { should eq 'A threshold has been exceeded.' }
    its(%w(logmsg dest)) { should eq 'logndisplay' }
    its(%w(logmsg notify)) { should be true }
    its(['severity']) { should eq 'Minor' }
    its(%w(alarmData reductionKey)) { should eq '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%' }
    its(%w(alarmData alarmType)) { should eq 1 }
    its(%w(alarmData autoClean)) { should be false }
  end
end
control 'OpenNMS Live Event REST API - chef4.events' do
  title 'chef4.events validation'
  events_data = opennms_event_api.fetch_live_eventconf_json('chef4.events')
  events_list = events_data['events'] || []
  describe opennms_event_api.fetch_live_eventconf('chef4.events') do
    its('exit_status') { should eq 0 }
  end
  describe 'chef4.events global profile data' do
    subject { events_data }
    its(['position']) { should eq 27 }
  end
  describe 'Event uei.opennms.org/fillerForANewThingInANewFile1' do
    subject { events_list.find { |e| e['uei'] == 'uei.opennms.org/fillerForANewThingInANewFile1' } }
    it { should_not be_nil }
    its(['eventLabel']) { should eq 'Chef defined event: thresholdExceeded' }
    its(['descr']) { should include 'A threshold defined by a chef recipe has been exceeded.' }
    its(%w(logmsg content)) { should eq 'A threshold has been exceeded.' }
    its(%w(logmsg dest)) { should eq 'logndisplay' }
    its(%w(logmsg notify)) { should be true }
    its(['severity']) { should eq 'Minor' }
    its(%w(alarmData reductionKey)) { should eq '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%' }
    its(%w(alarmData alarmType)) { should eq 1 }
    its(%w(alarmData autoClean)) { should be false }
  end
end
control 'OpenNMS Live Event REST API - chef4.events extensions' do
  title 'chef4.events validations'
  events_data = opennms_event_api.fetch_live_eventconf_json('chef4.events')
  events_list = events_data['events'] || []
  describe 'Event uei.opennms.org/fillerForANewThingInANewFile2' do
    subject { events_list.find { |e| e['uei'] == 'uei.opennms.org/fillerForANewThingInANewFile2' } }
    it { should_not be_nil }
    its(['eventLabel']) { should eq 'Chef defined event: thresholdExceeded' }
    its(['descr']) { should include 'A threshold defined by a chef recipe has been exceeded.' }
    its(%w(logmsg content)) { should eq 'A threshold has been exceeded.' }
    its(%w(logmsg dest)) { should eq 'logndisplay' }
    its(%w(logmsg notify)) { should be true }
    its(['severity']) { should eq 'Minor' }
    its(%w(alarmData reductionKey)) { should eq '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%' }
    its(%w(alarmData alarmType)) { should eq 1 }
    its(%w(alarmData autoClean)) { should be false }
  end
  describe 'Event uei.opennms.org/eventTopFileTop' do
    subject { events_list.find { |e| e['uei'] == 'uei.opennms.org/eventTopFileTop' } }
    it { should_not be_nil }
    its(['eventLabel']) { should eq 'Chef defined event: thresholdExceeded' }
    its(['descr']) { should include 'A threshold defined by a chef recipe has been exceeded.' }
    its(%w(logmsg content)) { should eq 'A threshold has been exceeded.' }
    its(%w(logmsg dest)) { should eq 'logndisplay' }
    its(%w(logmsg notify)) { should be true }
    its(['severity']) { should eq 'Minor' }
    its(%w(alarmData reductionKey)) { should eq '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%' }
  end
  describe 'Event uei.opennms.org/eventBottomFileTop' do
    subject { events_list.find { |e| e['uei'] == 'uei.opennms.org/eventBottomFileTop' } }
    it { should_not be_nil }
    its(['eventLabel']) { should eq 'Chef defined event: thresholdExceeded' }
    its(['descr']) { should include 'A threshold defined by a chef recipe has been exceeded.' }
    its(%w(logmsg content)) { should eq 'A threshold has been exceeded.' }
    its(%w(logmsg dest)) { should eq 'logndisplay' }
    its(%w(logmsg notify)) { should be true }
    its(['severity']) { should eq 'Minor' }
    its(%w(alarmData reductionKey)) { should eq '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%' }
  end
end
control 'OpenNMS Live Event REST API - chef5.events collection group' do
  title 'chef5.events validations'
  events_data = opennms_event_api.fetch_live_eventconf_json('chef5.events')
  events_list = events_data['events'] || []
  describe 'Event uei.opennms.org/collectionGroupTest' do
    subject { events_list.find { |e| e['uei'] == 'uei.opennms.org/collectionGroupTest' } }
    it { should_not be_nil }
    its(['eventLabel']) { should eq 'Chef defined event: thresholdExceeded' }
    its(['descr']) { should include 'collection group test.' }
    its(%w(logmsg content)) { should eq 'A collection group test.' }
    its(%w(logmsg dest)) { should eq 'logndisplay' }
    its(%w(logmsg notify)) { should be true }
    its(['severity']) { should eq 'Indeterminate' }
    it 'contains the correct collectionGroup attributes' do
      expect(subject['collectionGroup']).to include(
                                              hash_including(
                                                'name' => 'nodeGroup',
                                                'resourceType' => 'nodeSnmp',
                                                'instance' => 'instanceParmName'
                                              )
                                            )
    end
    it 'validates nested metric mappings inside the collection group' do
      group = (subject['collectionGroup'] || []).find { |g| g['name'] == 'nodeGroup' }
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
  events_data = opennms_event_api.fetch_live_eventconf_json('chef6.events')
  events_list = events_data['events'] || []
  describe 'Event uei.opennms.org/parametersTest' do
    subject { events_list.find { |e| e['uei'] == 'uei.opennms.org/parametersTest' } }
    it { should_not be_nil }
    its(['eventLabel']) { should eq 'Chef defined event: parametersTest' }
    its(['descr']) { should include 'parameters.' }
    its(%w(logmsg content)) { should eq 'parameters test.' }
    its(%w(logmsg dest)) { should eq 'logndisplay' }
    its(%w(logmsg notify)) { should be true }
    its(['severity']) { should eq 'Critical' }
    it 'contains the requested nested parameter mappings' do
      expect(subject['parameter']).to include(
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
  events_data = opennms_event_api.fetch_live_eventconf_json('chef6.events')
  events_list = events_data['events'] || []
  describe 'Event uei.opennms.org/operactionTest' do
    subject { events_list.find { |e| e['uei'] == 'uei.opennms.org/operactionTest' } }
    it { should_not be_nil }
    its(['eventLabel']) { should eq 'Chef defined event: operactionTest' }
    its(['descr']) { should include 'operactionTest.' }
    its(%w(logmsg content)) { should eq 'operactionTest test.' }
    its(%w(logmsg dest)) { should eq 'logndisplay' }
    its(%w(logmsg notify)) { should be true }
    its(['severity']) { should eq 'Warning' }
    it 'contains the correct operaction configurations' do
      expect(subject['operaction']).to include(
                                         hash_including(
                                           'content' => 'string',
                                           'state' => 'off',
                                           'menutext' => 'help me'
                                         )
                                       )
    end
  end
  describe 'Event uei.opennms.org/autoackTest' do
    subject { events_list.find { |e| e['uei'] == 'uei.opennms.org/autoackTest' } }
    it { should_not be_nil }
    its(['eventLabel']) { should eq 'Chef defined event: autoackTest' }
    its(['descr']) { should include 'autoackTest.' }
    its(%w(logmsg content)) { should eq 'autoackTest test.' }
    its(%w(logmsg dest)) { should eq 'logndisplay' }
    its(%w(logmsg notify)) { should be true }
    its(['severity']) { should eq 'Minor' }
    its(%w(autoacknowledge content)) { should eq 'please do not wake me up when the computer breaks' }
    its(%w(autoacknowledge state)) { should eq 'off' }
  end
  describe 'Event uei.opennms.org/filters' do
    subject { events_list.find { |e| e['uei'] == 'uei.opennms.org/filters' } }
    it { should_not be_nil }
    its(['eventLabel']) { should eq 'Chef defined event: filters' }
    its(['descr']) { should include 'filters.' }
    its(%w(logmsg content)) { should eq 'filters test.' }
    its(%w(logmsg dest)) { should eq 'logndisplay' }
    its(%w(logmsg notify)) { should be true }
    its(['severity']) { should eq 'Major' }
    it 'contains the correct eventFilter configurations' do
      expect(subject['eventFilter']).to include(
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
  events_data = opennms_event_api.fetch_live_eventconf_json('chef.events')
  events_list = events_data['events'] || []
  describe 'Event create_if_missing' do
    subject { events_list.find { |e| e['uei'] == 'create_if_missing' } }
    it { should_not be_nil }
    its(['eventLabel']) { should eq 'Chef defined event: createifmissing' }
    its(['descr']) { should include 'Trying to create a file if its missing.' }
    its(%w(logmsg content)) { should eq 'creating file if its missing.' }
    its(%w(logmsg dest)) { should eq 'logndisplay' }
    its(%w(logmsg notify)) { should be true }
    its(['severity']) { should eq 'Minor' }
  end
  describe 'Event noop_create_if_missing' do
    subject { events_list.find { |e| e['uei'] == 'noop_create_if_missing' } }
    it { should be_nil }
  end
end

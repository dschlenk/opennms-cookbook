# frozen_string_literal: true

control 'uei.opennms.org/cheftest/thresholdExceeded configurations' do
  describe 'OpenNMS Live Event REST API' do
    # Fetch the live JSON using the library helper method
    let(:api_response) { fetch_live_eventconf('chef.events') }

    # Parse the stdout payload into a Ruby hash if the API call succeeded
    let(:events_data) do
      return {} unless api_response.exit_status == 0
      JSON.parse(api_response.stdout)
    end

    # Safely dig down to the array of event definitions returned by OpenNMS
    let(:events_list) { events_data.dig('events') || [] }

    it 'connects to the OpenNMS REST API successfully' do
      expect(api_response.exit_status).to eq 0
    end

    # --- TEST CASE 1 ---
    it 'validates thresholdExceeded configuration' do
      evt = events_list.find { |e| e['uei'] == 'uei.opennms.org/cheftest/thresholdExceeded' }
      expect(evt).not_to be_nil

      expect(evt['eventLabel']).to eq 'Chef defined event: thresholdExceeded'
      expect(evt['descr']).to include 'A threshold defined by a chef recipe has been exceeded.'
      expect(evt.dig('logmsg', 'content')).to eq 'A threshold has been exceeded.'
      expect(evt.dig('logmsg', 'dest')).to eq 'logndisplay'
      expect(evt.dig('logmsg', 'notify')).to be true
      expect(evt['severity']).to eq 'Minor'
      expect(evt.dig('alarmData', 'reductionKey')).to eq '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%'
      expect(evt.dig('alarmData', 'alarmType')).to eq 1
      expect(evt.dig('alarmData', 'autoClean')).to be false
    end

    # --- TEST CASE 2 ---
    it 'validates thresholdExceeded2 configuration' do
      evt = events_list.find { |e| e['uei'] == 'uei.opennms.org/cheftest/thresholdExceeded2' }
      expect(evt).not_to be_nil

      expect(evt['eventLabel']).to eq 'Chef defined event: thresholdExceeded'
      expect(evt['descr']).to include 'A threshold defined by a chef recipe has been exceeded.'
      expect(evt.dig('logmsg', 'content')).to eq 'A threshold has been exceeded.'
      expect(evt.dig('logmsg', 'dest')).to eq 'logndisplay'
      expect(evt.dig('logmsg', 'notify')).to be true
      expect(evt['severity']).to eq 'Minor'
      expect(evt['operinstruct']).to eq 'the operinstruct'
      expect(evt['mouseovertext']).to eq 'mouseOverText'

      # Mask elements
      expect(evt.dig('mask', 'maskelement')).to include(
                                                  hash_including('mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1']),
                                                  hash_including('mename' => 'generic', 'mevalue' => ['6']),
                                                  hash_including('mename' => 'specific', 'mevalue' => ['2'])
                                                )

      # Complex structures
      expect(evt['autoaction']).to include(hash_including('content' => 'someaction', 'state' => 'off'))
      expect(evt['varbindsdecode']).to include(hash_including('parmid' => 'theParmId'))
      expect(evt.dig('tticket', 'content')).to eq 'tticketInfo'
      expect(evt.dig('tticket', 'state')).to eq 'off'
      expect(evt['forward']).to include(hash_including('content' => 'fwdInfo', 'state' => 'off', 'mechanism' => 'snmptcp'))
      expect(evt['script']).to include(hash_including('content' => 'anScript', 'language' => 'groovy'))
    end

    # --- TEST CASE 3 ---
    it 'validates thresholdExceeded3 configuration' do
      evt = events_list.find { |e| e['uei'] == 'uei.opennms.org/cheftest/thresholdExceeded3' }
      expect(evt).not_to be_nil

      expect(evt['eventLabel']).to eq 'Chef defined event: thresholdExceeded3'
      expect(evt['descr']).to include 'A threshold defined by a chef recipe has been exceeded3.'
      expect(evt.dig('logmsg', 'content')).to eq 'A threshold has been exceeded3.'
      expect(evt.dig('logmsg', 'dest')).to eq 'logndisplay'
      expect(evt.dig('logmsg', 'notify')).to be true
      expect(evt['severity']).to eq 'Minor'
      expect(evt['operinstruct']).to eq 'the operinstruct'
      expect(evt['mouseovertext']).to eq 'mouseOverText'
    end
  end
end

control 'uei.opennms.org/cheftest/thresholdExceeded 4 and 5 configurations' do
  describe 'OpenNMS Live Event REST API - chef.events' do
    let(:api_response) { fetch_live_eventconf('chef.events') }

    let(:events_data) do
      return {} unless api_response.exit_status == 0
      JSON.parse(api_response.stdout)
    end

    let(:events_list) { events_data.dig('events') || [] }

    # --- TEST CASE 4 ---
    it 'validates thresholdExceeded4 configuration' do
      evt = events_list.find { |e| e['uei'] == 'uei.opennms.org/cheftest/thresholdExceeded4' }
      expect(evt).not_to be_nil

      expect(evt['eventLabel']).to eq 'Chef defined event: thresholdExceeded4'
      expect(evt['descr']).to include 'A threshold defined by a chef recipe has been exceeded4.'
      expect(evt.dig('logmsg', 'content')).to eq 'A threshold has been exceeded4.'
      expect(evt.dig('logmsg', 'dest')).to eq 'logndisplay'
      expect(evt.dig('logmsg', 'notify')).to be true
      expect(evt['severity']).to eq 'Minor'
      expect(evt['operinstruct']).to eq 'the operinstruct'
      expect(evt['mouseovertext']).to eq 'mouseOverText'

      # Mask elements
      expect(evt.dig('mask', 'maskelement')).to include(
                                                  hash_including('mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1']),
                                                  hash_including('mename' => 'generic', 'mevalue' => ['6']),
                                                  hash_including('mename' => 'specific', 'mevalue' => ['2'])
                                                )

      # Complex structures
      expect(evt['autoaction']).to include(hash_including('content' => 'someaction', 'state' => 'off'))
      expect(evt['varbindsdecode']).to include(hash_including('parmid' => 'theParmId'))
      expect(evt.dig('tticket', 'content')).to eq 'tticketInfo'
      expect(evt.dig('tticket', 'state')).to eq 'off'
      expect(evt['forward']).to include(hash_including('content' => 'fwdInfo', 'state' => 'off', 'mechanism' => 'snmptcp'))
      expect(evt['script']).to include(hash_including('content' => 'anScript', 'language' => 'groovy'))
      expect(evt.dig('alarmData', 'reductionKey')).to eq '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%'
      expect(evt.dig('alarmData', 'alarmType')).to eq 1
      expect(evt.dig('alarmData', 'autoClean')).to be false
    end

    # --- TEST CASE 5 ---
    it 'validates thresholdExceeded5 configuration' do
      evt = events_list.find { |e| e['uei'] == 'uei.opennms.org/cheftest/thresholdExceeded5' }
      expect(evt).not_to be_nil

      expect(evt['eventLabel']).to eq 'Chef defined event: thresholdExceeded5'
      expect(evt['descr']).to include 'A threshold defined by a chef recipe has been exceeded4.'
      expect(evt.dig('logmsg', 'content')).to eq 'A threshold has been exceeded4.'
      expect(evt.dig('logmsg', 'dest')).to eq 'logndisplay'
      expect(evt.dig('logmsg', 'notify')).to be true
      expect(evt['severity']).to eq 'Minor'
      expect(evt['operinstruct']).to eq 'the operinstruct'
      expect(evt['mouseovertext']).to eq 'mouseOverText'

      # Mask elements including the vbnumber and vbvalue arrays
      expect(evt.dig('mask', 'maskelement')).to include(
                                                  hash_including('mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1']),
                                                  hash_including('mename' => 'generic', 'mevalue' => ['6']),
                                                  hash_including('mename' => 'specific', 'mevalue' => ['2']),
                                                  hash_including('vbnumber' => '1', 'vbvalue' => %w(1 2 3))
                                                )

      # Complex structures
      expect(evt['autoaction']).to include(hash_including('content' => 'someaction', 'state' => 'off'))
      expect(evt['varbindsdecode']).to include(hash_including('parmid' => 'theParmId'))
      expect(evt.dig('tticket', 'content')).to eq 'tticketInfo'
      expect(evt.dig('tticket', 'state')).to eq 'off'
      expect(evt['forward']).to include(hash_including('content' => 'fwdInfo', 'state' => 'off', 'mechanism' => 'snmptcp'))
      expect(evt['script']).to include(hash_including('content' => 'anScript', 'language' => 'groovy'))
      expect(evt.dig('alarmData', 'reductionKey')).to eq '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%'
      expect(evt.dig('alarmData', 'alarmType')).to eq 1
      expect(evt.dig('alarmData', 'autoClean')).to be false
    end
  end
end

control 'uei.opennms.org/anUeiForANewThingInANewFile absence verification' do
  describe 'OpenNMS Live Event REST API - chef2.events' do
    let(:api_response) { fetch_live_eventconf('chef2.events') }

    let(:events_data) do
      return {} unless api_response.exit_status == 0
      JSON.parse(api_response.stdout)
    end

    let(:events_list) { events_data.dig('events') || [] }

    it 'verifies that the event entry does not exist' do
      evt = events_list.find { |e| e['uei'] == 'uei.opennms.org/anUeiForANewThingInANewFile' }
      expect(evt).to be_nil
    end
  end
end

control 'OpenNMS Live Event REST API - chef3.events' do
  describe 'chef3.events validation' do
    let(:api_response) { fetch_live_eventconf('chef3.events') }

    let(:events_data) do
      return {} unless api_response.exit_status == 0
      JSON.parse(api_response.stdout)
    end

    let(:events_list) { events_data.dig('events') || [] }

    it 'verifies that the chef3.events profile configuration exists and sits at the correct position' do
      expect(api_response.exit_status).to eq 0
      # Validates global position block mapping if returned by the endpoint structure
      expect(events_data['position']).to eq 26
    end

    it 'validates anUeiForANewThingInANewFileWithPositionTop configuration' do
      evt = events_list.find { |e| e['uei'] == 'uei.opennms.org/anUeiForANewThingInANewFileWithPositionTop' }
      expect(evt).not_to be_nil

      expect(evt['eventLabel']).to eq 'Chef defined event: thresholdExceeded'
      expect(evt['descr']).to include 'A threshold defined by a chef recipe has been exceeded.'
      expect(evt.dig('logmsg', 'content')).to eq 'A threshold has been exceeded.'
      expect(evt.dig('logmsg', 'dest')).to eq 'logndisplay'
      expect(evt.dig('logmsg', 'notify')).to be true
      expect(evt['severity']).to eq 'Minor'
      expect(evt.dig('alarmData', 'reductionKey')).to eq '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%'
      expect(evt.dig('alarmData', 'alarmType')).to eq 1
      expect(evt.dig('alarmData', 'autoClean')).to be false
    end
  end
end

control 'OpenNMS Live Event REST API - chef4.events' do
  describe 'chef4.events validation' do
    let(:api_response) { fetch_live_eventconf('chef4.events') }

    let(:events_data) do
      return {} unless api_response.exit_status == 0
      JSON.parse(api_response.stdout)
    end

    let(:events_list) { events_data.dig('events') || [] }

    it 'verifies that the chef4.events profile configuration exists and sits at the correct position' do
      expect(api_response.exit_status).to eq 0
      expect(events_data['position']).to eq 27
    end

    it 'validates fillerForANewThingInANewFile1 configuration' do
      evt = events_list.find { |e| e['uei'] == 'uei.opennms.org/fillerForANewThingInANewFile1' }
      expect(evt).not_to be_nil

      expect(evt['eventLabel']).to eq 'Chef defined event: thresholdExceeded'
      expect(evt['descr']).to include 'A threshold defined by a chef recipe has been exceeded.'
      expect(evt.dig('logmsg', 'content')).to eq 'A threshold has been exceeded.'
      expect(evt.dig('logmsg', 'dest')).to eq 'logndisplay'
      expect(evt.dig('logmsg', 'notify')).to be true
      expect(evt['severity']).to eq 'Minor'
      expect(evt.dig('alarmData', 'reductionKey')).to eq '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%'
      expect(evt.dig('alarmData', 'alarmType')).to eq 1
      expect(evt.dig('alarmData', 'autoClean')).to be false
    end
  end
end

control 'OpenNMS Live Event REST API - chef4.events extensions' do
  describe 'chef4.events validations' do
    let(:api_response) { fetch_live_eventconf('chef4.events') }

    let(:events_data) do
      return {} unless api_response.exit_status == 0
      JSON.parse(api_response.stdout)
    end

    let(:events_list) { events_data.dig('events') || [] }

    it 'validates fillerForANewThingInANewFile2 configuration' do
      evt = events_list.find { |e| e['uei'] == 'uei.opennms.org/fillerForANewThingInANewFile2' }
      expect(evt).not_to be_nil

      expect(evt['eventLabel']).to eq 'Chef defined event: thresholdExceeded'
      expect(evt['descr']).to include 'A threshold defined by a chef recipe has been exceeded.'
      expect(evt.dig('logmsg', 'content')).to eq 'A threshold has been exceeded.'
      expect(evt.dig('logmsg', 'dest')).to eq 'logndisplay'
      expect(evt.dig('logmsg', 'notify')).to be true
      expect(evt['severity']).to eq 'Minor'
      expect(evt.dig('alarmData', 'reductionKey')).to eq '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%'
      expect(evt.dig('alarmData', 'alarmType')).to eq 1
      expect(evt.dig('alarmData', 'autoClean')).to be false
    end

    it 'validates eventTopFileTop configuration' do
      evt = events_list.find { |e| e['uei'] == 'uei.opennms.org/eventTopFileTop' }
      expect(evt).not_to be_nil

      expect(evt['eventLabel']).to eq 'Chef defined event: thresholdExceeded'
      expect(evt['descr']).to include 'A threshold defined by a chef recipe has been exceeded.'
      expect(evt.dig('logmsg', 'content')).to eq 'A threshold has been exceeded.'
      expect(evt.dig('logmsg', 'dest')).to eq 'logndisplay'
      expect(evt.dig('logmsg', 'notify')).to be true
      expect(evt['severity']).to eq 'Minor'
      expect(evt.dig('alarmData', 'reductionKey')).to eq '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%'
    end

    it 'validates eventBottomFileTop configuration' do
      evt = events_list.find { |e| e['uei'] == 'uei.opennms.org/eventBottomFileTop' }
      expect(evt).not_to be_nil

      expect(evt['eventLabel']).to eq 'Chef defined event: thresholdExceeded'
      expect(evt['descr']).to include 'A threshold defined by a chef recipe has been exceeded.'
      expect(evt.dig('logmsg', 'content')).to eq 'A threshold has been exceeded.'
      expect(evt.dig('logmsg', 'dest')).to eq 'logndisplay'
      expect(evt.dig('logmsg', 'notify')).to be true
      expect(evt['severity']).to eq 'Minor'
      expect(evt.dig('alarmData', 'reductionKey')).to eq '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%'
    end
  end
end

control 'OpenNMS Live Event REST API - chef5.events collection group' do
  describe 'chef5.events validations' do
    let(:api_response) { fetch_live_eventconf('chef5.events') }

    let(:events_data) do
      return {} unless api_response.exit_status == 0
      JSON.parse(api_response.stdout)
    end

    let(:events_list) { events_data.dig('events') || [] }

    it 'validates collectionGroupTest configuration and nested metric mapping' do
      evt = events_list.find { |e| e['uei'] == 'uei.opennms.org/collectionGroupTest' }
      expect(evt).not_to be_nil

      expect(evt['eventLabel']).to eq 'Chef defined event: thresholdExceeded'
      expect(evt['descr']).to include 'collection group test.'
      expect(evt.dig('logmsg', 'content')).to eq 'A collection group test.'
      expect(evt.dig('logmsg', 'dest')).to eq 'logndisplay'
      expect(evt.dig('logmsg', 'notify')).to be true
      expect(evt['severity']).to eq 'Indeterminate'

      expect(evt['collectionGroup']).to include(
                                          hash_including(
                                            'name' => 'nodeGroup',
                                            'resourceType' => 'nodeSnmp',
                                            'instance' => 'instanceParmName'
                                          )
                                        )

      group = evt['collectionGroup']&.find { |g| g['name'] == 'nodeGroup' }
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
  describe 'chef6.events validations' do
    let(:api_response) { fetch_live_eventconf('chef6.events') }

    let(:events_data) do
      return {} unless api_response.exit_status == 0
      JSON.parse(api_response.stdout)
    end

    let(:events_list) { events_data.dig('events') || [] }

    it 'validates parametersTest configuration and specific parameter array blocks' do
      evt = events_list.find { |e| e['uei'] == 'uei.opennms.org/parametersTest' }
      expect(evt).not_to be_nil

      expect(evt['eventLabel']).to eq 'Chef defined event: parametersTest'
      expect(evt['descr']).to include 'parameters.'
      expect(evt.dig('logmsg', 'content')).to eq 'parameters test.'
      expect(evt.dig('logmsg', 'dest')).to eq 'logndisplay'
      expect(evt.dig('logmsg', 'notify')).to be true
      expect(evt['severity']).to eq 'Critical'

      # Validates nested parameter mappings in OpenNMS API schema syntax
      expect(evt['parameter']).to include(
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
  describe 'chef6.events structural validations' do
    let(:api_response) { fetch_live_eventconf('chef6.events') }

    let(:events_data) do
      return {} unless api_response.exit_status == 0
      JSON.parse(api_response.stdout)
    end

    let(:events_list) { events_data.dig('events') || [] }

    it 'validates operactionTest configuration' do
      evt = events_list.find { |e| e['uei'] == 'uei.opennms.org/operactionTest' }
      expect(evt).not_to be_nil

      expect(evt['eventLabel']).to eq 'Chef defined event: operactionTest'
      expect(evt['descr']).to include 'operactionTest.'
      expect(evt.dig('logmsg', 'content')).to eq 'operactionTest test.'
      expect(evt.dig('logmsg', 'dest')).to eq 'logndisplay'
      expect(evt.dig('logmsg', 'notify')).to be true
      expect(evt['severity']).to eq 'Warning'

      # Matches OpenNMS camelCase structure for operaction arrays
      expect(evt['operaction']).to include(
                                     hash_including(
                                       'content' => 'string',
                                       'state' => 'off',
                                       'menutext' => 'help me'
                                     )
                                   )
    end

    it 'validates autoackTest configuration' do
      evt = events_list.find { |e| e['uei'] == 'uei.opennms.org/autoackTest' }
      expect(evt).not_to be_nil

      expect(evt['eventLabel']).to eq 'Chef defined event: autoackTest'
      expect(evt['descr']).to include 'autoackTest.'
      expect(evt.dig('logmsg', 'content')).to eq 'autoackTest test.'
      expect(evt.dig('logmsg', 'dest')).to eq 'logndisplay'
      expect(evt.dig('logmsg', 'notify')).to be true
      expect(evt['severity']).to eq 'Minor'

      # Matches JSON parsing of autoacknowledge object fields
      expect(evt.dig('autoacknowledge', 'content')).to eq 'please do not wake me up when the computer breaks'
      expect(evt.dig('autoacknowledge', 'state')).to eq 'off'
    end

    it 'validates filters configuration' do
      evt = events_list.find { |e| e['uei'] == 'uei.opennms.org/filters' }
      expect(evt).not_to be_nil

      expect(evt['eventLabel']).to eq 'Chef defined event: filters'
      expect(evt['descr']).to include 'filters.'
      expect(evt.dig('logmsg', 'content')).to eq 'filters test.'
      expect(evt.dig('logmsg', 'dest')).to eq 'logndisplay'
      expect(evt.dig('logmsg', 'notify')).to be true
      expect(evt['severity']).to eq 'Major'

      # Matches lowerCamelCase array for eventFilters schema properties
      expect(evt['eventFilter']).to include(
                                      hash_including(
                                        'eventparm' => 'one',
                                        'pattern' => '/^one&two{;t|hreehalo$/',
                                        'replacement' => 'poop'
                                      )
                                    )
    end
  end

  only_if('NMS-19814 is resolved') do
    false
  end
end

control 'OpenNMS Live Event REST API - chef.events file actions' do
  describe 'chef.events file creation state validations' do
    let(:api_response) { fetch_live_eventconf('chef.events') }

    let(:events_data) do
      return {} unless api_response.exit_status == 0
      JSON.parse(api_response.stdout)
    end

    let(:events_list) { events_data.dig('events') || [] }

    it 'validates create_if_missing event entry' do
      evt = events_list.find { |e| e['uei'] == 'create_if_missing' }
      expect(evt).not_to be_nil

      expect(evt['eventLabel']).to eq 'Chef defined event: createifmissing'
      expect(evt['descr']).to include 'Trying to create a file if its missing.'
      expect(evt.dig('logmsg', 'content')).to eq 'creating file if its missing.'
      expect(evt.dig('logmsg', 'dest')).to eq 'logndisplay'
      expect(evt.dig('logmsg', 'notify')).to be true
      expect(evt['severity']).to eq 'Minor'
    end

    it 'verifies that noop_create_if_missing entry does not exist' do
      evt = events_list.find { |e| e['uei'] == 'noop_create_if_missing' }
      expect(evt).to be_nil
    end
  end
end

# frozen_string_literal: true

control 'uei.opennms.org/cheftest/thresholdExceeded configurations' do
  title 'OpenNMS Live Event REST API'

  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded', 'events/chef.events.xml') do
    it 'validates live event properties correctly' do
      expect(subject).to_not be_nil
      expect(subject['event_label']).to eq 'Chef defined event: thresholdExceeded'
      expect(subject['descr']).to include 'A threshold defined by a chef recipe has been exceeded.'
      expect(subject['logmsg']).to eq 'A threshold has been exceeded.'
      expect(subject['logmsg_dest']).to eq 'logndisplay'
      expect(subject['logmsg_notify']).to be true
      expect(subject['severity']).to eq 'Minor'

      alarm = subject['alarm_data'] || {}
      expect(alarm['reduction_key']).to eq '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%'
      expect(alarm['alarm_type']).to eq 1
      expect(alarm['auto_clean']).to be false
    end
  end

  # Script Modifiers Validation Block
  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded2-script', 'events/chef.events.xml') do
    it 'contains all base event attributes and modifiers' do
      expect(subject).to_not be_nil
      expect(subject['event_label']).to eq 'Chef defined event: thresholdExceeded'
      expect(subject['descr']).to include 'A threshold defined by a chef recipe has been exceeded.'
      expect(subject['logmsg']).to eq 'A threshold has been exceeded.'
      expect(subject['logmsg_dest']).to eq 'logndisplay'
      expect(subject['logmsg_notify']).to be true
      expect(subject['severity']).to eq 'Minor'
      expect(subject['operinstruct']).to eq 'the operinstruct'
      expect(subject['mouseovertext']).to eq 'mouseOverText'

      ticket = subject['tticket'] || {}
      expect(ticket['info']).to eq 'tticketInfo'
      expect(ticket['state']).to eq 'off'
    end

    it 'contains the required mask elements' do
      mask_elements = subject.dig('mask', 'maskelement') || subject['mask'] || []
      expect(mask_elements).to include(
                                 hash_including('mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1']),
                                 hash_including('mename' => 'generic', 'mevalue' => ['6']),
                                 hash_including('mename' => 'specific', 'mevalue' => ['2'])
                               )
    end

    it 'contains the required autoaction attributes' do
      expect(Array(subject['autoaction'])).to include(hash_including('action' => 'someaction', 'state' => 'off'))
    end

    it 'contains the required varbindsdecode values' do
      expect(Array(subject['varbindsdecode'])).to include(hash_including('parmid' => 'theParmId'))
    end

    it 'contains the required forward configuration payloads' do
      expect(Array(subject['forward'])).to include(hash_including('info' => 'fwdInfo', 'state' => 'off', 'mechanism' => 'snmptcp'))
    end

    it 'contains the required script properties' do
      expect(Array(subject['script'])).to include(hash_including('name' => 'anScript', 'language' => 'groovy'))
    end
  end

  # Structural Top Check
  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded3', 'events/chef.events.xml') do
    it 'verifies top position block data setup' do
      expect(subject).to_not be_nil
      expect(subject['event_label']).to eq 'Chef defined event: thresholdExceeded3'
      expect(subject['descr']).to include 'A threshold defined by a chef recipe has been exceeded3.'
      expect(subject['logmsg']).to eq 'A threshold has been exceeded3.'
      expect(subject['logmsg_dest']).to eq 'logndisplay'
      expect(subject['logmsg_notify']).to be true
      expect(subject['severity']).to eq 'Minor'
    end
  end
end

control 'uei.opennms.org/cheftest/thresholdExceeded 4 and 5 configurations' do
  title 'OpenNMS Live Event REST API - chef.events'

  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded4-complex', 'events/chef.events.xml') do
    it 'validates complex configuration properties' do
      expect(subject).to_not be_nil
      expect(subject['event_label']).to eq 'Chef defined event: thresholdExceeded4'
      expect(subject['descr']).to include 'A threshold defined by a chef recipe has been exceeded4.'
      expect(subject['logmsg']).to eq 'A threshold has been exceeded4.'
      expect(subject['logmsg_dest']).to eq 'logndisplay'
      expect(subject['logmsg_notify']).to be true
      expect(subject['severity']).to eq 'Minor'
      expect(subject['operinstruct']).to eq 'the operinstruct'
      expect(subject['mouseovertext']).to eq 'mouseOverText'

      ticket = subject['tticket'] || {}
      expect(ticket['info']).to eq 'tticketInfo'
      expect(ticket['state']).to eq 'off'

      alarm = subject['alarm_data'] || {}
      expect(alarm['reduction_key']).to eq '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%'
      expect(alarm['alarm_type']).to eq 1
      expect(alarm['auto_clean']).to be false
    end

    it 'contains the required complex structures matching attributes' do
      expect(Array(subject['autoaction'])).to include(hash_including('action' => 'someaction', 'state' => 'off'))
      expect(Array(subject['varbindsdecode'])).to include(hash_including('parmid' => 'theParmId'))
      expect(Array(subject['forward'])).to include(hash_including('info' => 'fwdInfo', 'state' => 'off', 'mechanism' => 'snmptcp'))
      expect(Array(subject['script'])).to include(hash_including('name' => 'anScript', 'language' => 'groovy'))
    end
  end

  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded5-arrays', 'events/chef.events.xml') do
    it 'verifies complex list array mapping layout descriptions' do
      expect(subject).to_not be_nil
      expect(subject['event_label']).to eq 'Chef defined event: thresholdExceeded5'
      expect(subject['descr']).to include 'A threshold defined by a chef recipe has been exceeded4.'
      expect(subject['logmsg']).to eq 'A threshold has been exceeded4.'
      expect(subject['logmsg_dest']).to eq 'logndisplay'
      expect(subject['logmsg_notify']).to be true
      expect(subject['severity']).to eq 'Minor'

      alarm = subject['alarm_data'] || {}
      expect(alarm['reduction_key']).to eq '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%'
    end

    it 'contains the required mask elements including vbnumber and vbvalue arrays' do
      mask_elements = subject.dig('mask', 'maskelement') || subject['mask'] || []
      varbind_elements = subject.dig('mask', 'varbind') || []

      expect(mask_elements).to include(
                                 hash_including('mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1']),
                                 hash_including('mename' => 'generic', 'mevalue' => ['6']),
                                 hash_including('mename' => 'specific', 'mevalue' => ['2'])
                               )
      expect(varbind_elements).to include(
                                    hash_including('vbnumber' => '1', 'vbvalue' => %w[1 2 3])
                                  )
    end
  end
end

control 'uei.opennms.org/anUeiForANewThingInANewFile absence verification' do
  title 'OpenNMS Live Event REST API - chef2.events'

  describe opennms_event('uei.opennms.org/anUeiForANewThingInANewFile-absent', 'events/chef2.events.xml') do
    it 'expects configuration entity state data structures to be empty' do
      expect(subject.empty? || subject['uei'].nil?).to be true
    end
  end
end

control 'OpenNMS Live Event REST API - chef3.events and chef4.events position validations' do
  title 'Position isolated validations'

  describe opennms_event('uei.opennms.org/anUeiForANewThingInANewFileWithPositionTop-isolated', 'events/chef3.events.xml') do
    it 'verifies basic properties' do
      expect(subject).to_not be_nil
      expect(subject['severity']).to eq 'Minor'

      alarm = subject['alarm_data'] || {}
      expect(alarm['reduction_key']).to eq '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%'
      expect(alarm['alarm_type']).to eq 1
      expect(alarm['auto_clean']).to be false
    end
  end

  describe opennms_event('uei.opennms.org/fillerForANewThingInANewFile1-isolated', 'events/chef4.events.xml') do
    it('verifies event initialization pipeline sync') { expect(subject).to_not be_nil }
  end

  describe opennms_event('uei.opennms.org/fillerForANewThingInANewFile2-isolated', 'events/chef4.events.xml') do
    it('verifies event initialization pipeline sync') { expect(subject).to_not be_nil }
  end

  describe opennms_event('uei.opennms.org/eventTopFileTop-isolated', 'events/chef4.events.xml') do
    it('verifies event initialization pipeline sync') { expect(subject).to_not be_nil }
  end

  describe opennms_event('uei.opennms.org/eventBottomFileTop-isolated', 'events/chef4.events.xml') do
    it('verifies event initialization pipeline sync') { expect(subject).to_not be_nil }
  end
end

control 'OpenNMS Live Event REST API - chef5.events collection group' do
  title 'chef5.events validations'

  describe opennms_event('uei.opennms.org/collectionGroupTest-isolated', 'events/chef5.events.xml') do
    it 'validates correct collection properties' do
      expect(subject).to_not be_nil
      expect(subject['severity']).to eq 'Indeterminate'
    end

    it 'contains the correct collectionGroup attributes' do
      group = subject['collectionGroup'] || subject['collection_group'] || []
      expect(Array(group)).to include(
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
    it 'validates base state values' do
      expect(subject).to_not be_nil
      expect(subject['severity']).to eq 'Critical'
    end
    it 'contains the requested nested parameter mappings' do
      expect(Array(subject['parameter'])).to include(
                                               hash_including(
                                                 'name' => 'paramName',
                                                 'value' => 'someString',
                                                 'expand' => true
                                               )
                                             )
    end
  end

  describe opennms_event('uei.opennms.org/autoackTest-isolated', 'events/chef6.events.xml') do
    it 'verifies autoacknowledge data fields cleanly' do
      expect(subject).to_not be_nil
      expect(subject['severity']).to eq 'Minor'
      ack = subject['autoacknowledge'] || {}
      expect(ack['info']).to eq 'please do not wake me up when the computer breaks'
      expect(ack['state']).to eq 'off'
    end
  end

  describe opennms_event('uei.opennms.org/filters-isolated', 'events/chef6.events.xml') do
    it 'verifies filters metadata records layout' do
      expect(subject).to_not be_nil
      expect(subject['severity']).to eq 'Major'
    end
    it 'contains the correct eventFilter configurations matching the recipe values' do
      filters = subject['filter'] || subject['filters'] || []
      expect(Array(filters)).to include(
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
    it 'validates the create_if_missing resource mappings structure' do
      expect(subject).to_not be_nil
      expect(subject['event_label']).to eq 'Chef defined event: createifmissing'
      expect(subject['severity']).to eq 'Minor'
    end
    it 'ensures unexpected configurations are absent' do
      expect(subject['event_label']).to_not eq 'Chef defined event: noopcreateifmissing'
    end
  end
end

control 'OpenNMS Live Event REST API - Dynamic Outage Loops' do
  title 'Pollerd certificate loops validation'
  [443, 8443].each do |port|
    [60, 30].each do |_days|
      describe opennms_event('uei.opennms.org/nodes/nodeLostService', 'events/opennms.pollerd.events.xml') do
        it 'validates out-of-the-box system configurations dynamically generated looping rules' do
          expect(subject).to_not be_nil
          expect(subject['event_label']).to eq 'OpenNMS-defined node event: nodeLostService'
          expect(subject['logmsg_dest']).to eq 'logndisplay'
        end
      end
    end
  end
end

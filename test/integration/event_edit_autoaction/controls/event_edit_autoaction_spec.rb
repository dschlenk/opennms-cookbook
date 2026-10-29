# frozen_string_literal: true

control 'event_edit_autoaction' do
  title 'OpenNMS Event Autoaction Configuration'

  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded2-event_edit_autoaction', 'events/chef.events.xml') do
    it { should exist }

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

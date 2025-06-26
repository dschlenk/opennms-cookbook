control 'jms_nb_destination' do
  describe jms_nb_destination('foo') do
    it { should exist }
    its('first_occurence_only') { should eq true }
    its('send_as_object_message') { should eq false }
    its('destination_type') { should eq 'QUEUE' }
    its('message_format') { should eq 'ALARM ID:${alarmId} NODE:${nodeLabel}; ${logMsg}' }
  end

  describe jms_nb_destination('bar') do
    it { should exist }
    its('first_occurence_only') { should eq false }
    its('send_as_object_message') { should eq true }
    its('destination_type') { should eq 'TOPIC' }
    its('message_format') { should eq 'ALARM: ${logMsg}' }
  end

  describe jms_nb_destination('baz') do
    it { should exist }
    its('first_occurence_only') { should eq false }
    its('send_as_object_message') { should eq false }
    its('destination_type') { should eq 'QUEUE' }
    its('message_format') { should eq 'ALARM ID:${alarmId} - ${logMsg}' }
  end

  describe jms_nb_destination('delete') do
    it { should_not exist }
  end

  describe jms_nb_destination('nope') do
    it { should_not exist }
  end

  describe jms_nb_destination('404') do
    it { should_not exist }
  end
end

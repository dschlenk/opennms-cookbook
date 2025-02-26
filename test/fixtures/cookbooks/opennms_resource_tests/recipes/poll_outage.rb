# frozen_string_literal: true
# most useful options
opennms_poll_outage 'create ignore localhost on mondays' do
  outage_name 'ignore localhost on mondays'
  type 'weekly'
  times 'mondays' => { 'day' => 'monday', 'begins' => '00:00:00', 'ends' => '23:59:59' }
  interfaces ['127.0.0.1']
  notifies :run, 'opennms_send_event[activate_poll-outages.xml]', :delayed
end

opennms_poll_outage 'create ignore node 1 on mondays' do
  outage_name 'ignore node 1 on mondays'
  type 'weekly'
  times 'mondays' => { 'day' => 'monday', 'begins' => '00:00:00', 'ends' => '23:59:59' }
  nodes [1]
  notifies :run, 'opennms_send_event[activate_poll-outages.xml]', :delayed
end

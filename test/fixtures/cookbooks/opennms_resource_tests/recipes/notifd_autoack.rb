# example with all options
opennms_notifd_autoack 'uei.opennms.org/example/exampleUp' do
  acknowledge 'uei.opennms.org/example/exampleDown'
  resolution_prefix 'RECTIFIED: '
  notify false
  matches %w(nodeid interfaceid serviceid)
end

# minimal options - will use 'nodeid' as the only match element
opennms_notifd_autoack 'example2/exampleFixed' do
  acknowledge 'example2/exampleBroken'
end

# example of :create_if_missing that does something
opennms_notifd_autoack 'exampl3/exampl3' do
  acknowledge 'exampl3/exampl3Down'
  resolution_prefix 'RESOLVED: '
  action :create_if_missing
end

# example of :create_if_missing that does nothing
opennms_notifd_autoack 'exampl3/exampl3' do
  acknowledge 'exampl3/exampl3Down'
  resolution_prefix 'RECTIFIED: '
  notify false
  action :create_if_missing
end

# create and update
opennms_notifd_autoack 'example4/up' do
  acknowledge 'example4/down'
end
opennms_notifd_autoack 'update example4/up, example4/down' do
  uei 'example4/up'
  acknowledge 'example4/down'
  resolution_prefix 'EVERYTHING_IS_FINE_DOT_GIF: '
  matches %w(nodeid interfaceid serviceid)
  notify true
  action :update
end

# create and delete
opennms_notifd_autoack 'example5/up' do
  acknowledge 'example5/down'
end
opennms_notifd_autoack 'delete example5/up, example5/down' do
  uei 'example5/up'
  acknowledge 'example5/down'
  action :delete
end

# delete something that doesn't exist
opennms_notifd_autoack 'delete example6/up, example5/down' do
  uei 'example6/up'
  acknowledge 'example6/down'
  action :delete
end

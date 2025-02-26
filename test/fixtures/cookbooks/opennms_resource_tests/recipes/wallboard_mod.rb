opennms_wallboard 'fooboard' do
  set_default true
end

opennms_wallboard 'schlazorboard' do
  set_default false
end

opennms_wallboard 'barboard' do
  action :delete
end

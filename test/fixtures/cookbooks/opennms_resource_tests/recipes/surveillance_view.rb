opennms_surveillance_view 'default' do
  rows 'Routers' => ['Routers'], 'Servers' => ['Servers']
  columns 'PROD' => ['Production'], 'TEST' => %w(Test Development)
end

# make another one, and make it default
opennms_surveillance_view 'foo-view' do
  rows 'Routers' => ['Routers'], 'Switches' => ['Switches'], 'Servers' => ['Servers']
  columns 'PROD' => ['Production'], 'TEST' => ['Test'], 'DEV' => ['Development']
  default_view true
end

# another one that is not default and is the inverse
opennms_surveillance_view 'bar-view' do
  rows 'PROD' => ['Production'], 'TEST' => ['Test'], 'DEV' => ['Development']
  columns 'Routers' => ['Routers'], 'Switches' => ['Switches'], 'Servers' => ['Servers']
  refresh_seconds 600
  default_view false
end

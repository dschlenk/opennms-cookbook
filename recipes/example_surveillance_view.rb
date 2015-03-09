# modify the default view
opennms_surveillance_view 'default' do
  rows 'Routers' => ['Routers'], 'Servers' => ['Servers']
  columns 'PROD' => ['Production'], 'TEST' => ['Test', 'Development']
end

# make another one, and make it default
opennms_surveillance_view 'foo-view' do
  rows 'Routers' => ['Routers'], 'Switches' => ['Switches'], 'Servers' => ['Servers']
  columns 'PROD' => ['Production'], 'TEST' => ['Test'], 'DEV' => ['Development']
  default_view true
end

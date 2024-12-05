include_recipe 'opennms_resource_tests::surveillance_view'
# should do nothing
opennms_surveillance_view 'default' do
  rows 'Routers' => ['Routers']
  columns 'PROD' => ['Production'], 'TEST' => %w(Test Development)
  action :create_if_missing
end

# delete the default view
opennms_surveillance_view 'foo-view' do
  action :delete
end

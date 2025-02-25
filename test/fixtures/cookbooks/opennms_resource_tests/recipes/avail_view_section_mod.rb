include_recipe 'opennms_resource_tests::avail_view_section'

# should work
opennms_avail_view_section 'Dogs First' do
  categories %w(Cats)
  action :update
end

# should do nothing
opennms_avail_view_section 'Topmost' do
  categories ['Database Servers', 'Noop']
  action :create_if_missing
end

opennms_avail_view_section 'Bottommost' do
  action :delete
end

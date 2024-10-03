include_recipe 'opennms_resource_tests::avail_category'
# change some stuff in the OOTB view
opennms_avail_view_section 'Categories' do
  categories ['Network Interfaces', 'Web Servers', 'Other Servers']
end

# Add a new section
opennms_avail_view_section 'Animals' do
  categories %w(Cats Dogs)
  before 'Categories'
end

opennms_avail_view_section 'Dogs First' do
  categories %w(Dogs Cats)
  after 'Categories'
end

# default position is 'top'
opennms_avail_view_section 'Topmost' do
  categories ['Database Servers']
end

opennms_avail_view_section 'Bottommost' do
  categories ['Other Servers']
  position 'bottom'
end

control 'avail_view_section_mod' do
  sections = { 
    'Topmost' => { 
      'categories' => ['Database Servers'],
      'position' => 1,
    },
   'Animals' => {
     'categories' => %w(Cats Dogs),
     'position' => 2,
   },
   'Categories' => {
     'categories' => ['Network Interfaces', 'Web Servers', 'Other Servers'],
     'position' => 3,
   },
   'Dogs First' => {
     'categories' => %w(Cats),
     'position' => 4,
   },
   'Total' => {
     'categories' => ['Overall Service Availability'],
     'position' => 5,
   },
  }
  sections.each do |section, properties|
    describe avail_view_section(section) do
      its('categories') { should eq properties['categories'] }
      its('position') { should eq properties['position'] }
    end
  end
  describe avail_view_section('Bottommost') do
    it { should_not exist }
  end
end

control 'avail_view_section' do
  sections = { 'Topmost' => {
      'categories' => ['Database Servers'],
      'position' => 4
    },
    'Animals' => {
      'categories' => ['Cats', 'Dogs'],
      'position' => 6
    },
    'Categories' => {
      'categories' => ['Network Interfaces', 'Web Servers', 'Other Servers'],
      'position' => 8
    },
    'Dogs First' => {
      'categories' => ['Dogs', 'Cats'],
      'position' => 10
    },
    'Total' => {
      'categories' => ['Overall Service Availability'],
      'position' => 12
    },
    'Bottommost' => {
      'categories' => ['Other Servers'],
      'position' => 14
    }
  }
  sections.each do |section, properties|
    describe avail_view_section(section) do
      its('categories') { should eq properties['categories'] }
      its('position') { should eq properties['position'] }
    end
  end
end

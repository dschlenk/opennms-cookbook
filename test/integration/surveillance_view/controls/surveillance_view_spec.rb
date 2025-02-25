control 'surveillance_view' do
  describe surveillance_view('default') do
    it { should exist }
    its('rows') { should eq 'Routers' => ['Routers'], 'Servers' => ['Servers'] }
    its('columns') { should eq 'PROD' => ['Production'], 'TEST' => %w(Test Development) }
    its('refresh_seconds') { should be == 300 }
    its('default_view') { should eq false }
  end

  describe surveillance_view('foo-view') do
    it { should exist }
    its('rows') { should eq 'Routers' => ['Routers'], 'Switches' => ['Switches'], 'Servers' => ['Servers'] }
    its('columns') { should eq 'PROD' => ['Production'], 'TEST' => ['Test'], 'DEV' => ['Development'] }
    its('refresh_seconds') { should eq nil }
    its('default_view') { should eq true }
  end

  describe surveillance_view('bar-view') do
    it { should exist }
    its('columns') { should eq 'Routers' => ['Routers'], 'Switches' => ['Switches'], 'Servers' => ['Servers'] }
    its('rows') { should eq 'PROD' => ['Production'], 'TEST' => ['Test'], 'DEV' => ['Development'] }
    its('refresh_seconds') { should be == 600 }
    its('default_view') { should eq false }
  end
end

# frozen_string_literal: true
control 'surveillance_view' do
  describe surveillance_view('default') do
    it { should exist }
    its('rows') { should eq 'Routers' => ['Routers'], 'Servers' => ['Servers'] }
    its('columns') { should eq 'PROD' => ['Production'], 'TEST' => %w(Test Development) }
  end

  describe surveillance_view('foo-view') do
    it { should exist }
    its('rows') { should eq 'Routers' => ['Routers'], 'Switches' => ['Switches'], 'Servers' => ['Servers'] }
    its('columns') { should eq 'PROD' => ['Production'], 'TEST' => ['Test'], 'DEV' => ['Development'] }
    its('default_view') { should eq true }
  end
end

# frozen_string_literal: true
control 'destination_path' do
  describe destination_path('foo') do
    it { should exist }
    its('initial_delay') { should eq '5s' }
  end

  describe destination_path('bar') do
    it { should exist }
  end

  describe target('foo', 'Admin') do
    it { should exist }
    its('commands') { should eq ['javaEmail'] }
  end

  describe target('bar', 'Admin') do
    it { should exist }
    its('commands') { should eq ['javaPagerEmail'] }
  end
end

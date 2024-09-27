# frozen_string_literal: true
describe package('opennms-core') do
  it { should be_installed }
  its('version') { should eq '33.0.8-1' }
end
describe package('opennms-webapp-jetty') do
  it { should be_installed }
  its('version') { should eq '33.0.8-1' }
end
describe service('opennms') do
  it { should be_enabled }
  it { should be_installed }
  it { should be_running }
end

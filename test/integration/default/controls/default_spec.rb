# frozen_string_literal: true
describe 'opennms::default' do
  let(:node) { json('/tmp/kitchen/dna.json').params }
  it 'installs opennms' do
    expect(package('opennms-core')).to be_installed
    expect(package('opennms-webapp-jetty')).to be_installed
    if node['opennms']['version'].to_i < 28
      expect(package('opennms-docs')).to be_installed
    end
  end
end
describe service('opennms') do
  it { should be_enabled }
  it { should be_installed }
  it { should be_running }
end

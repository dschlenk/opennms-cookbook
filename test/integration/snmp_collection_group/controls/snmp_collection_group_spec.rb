# frozen_string_literal: true
control 'snmp_collection_group' do
  describe snmp_collection_group('wibble-wobble', 'wibble-wobble.xml', 'baz') do
    it { should exist }
    its('system_def') { should eq 'Wibble' }
  end
end

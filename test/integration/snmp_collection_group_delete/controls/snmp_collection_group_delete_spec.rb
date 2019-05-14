# frozen_string_literal: true
control 'wibble-wobble in baz is not present' do
  describe snmp_collection_group('wibble-wobble', 'wibble-wobble.xml', 'baz') do
    it { should_not exist }
  end
end

control 'group-name-to-delete in collection-name-to-delete is not present' do
  describe snmp_collection_group('group-name-to-delete', 'file-name-to-delete.xml', 'collection-name-to-delete') do
    it { should_not exist }
  end
end

control 'group-name-tobe-delete in default is not present' do
  describe snmp_collection_group('group-name-tobe-delete', 'file-name-to-delete.xml', 'default') do
    it { should_not exist }
  end
end

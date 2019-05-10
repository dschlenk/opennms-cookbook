# frozen_string_literal: true
control 'snmp_collection_group_delete' do
	describe snmp_collection_group('group-name-to-delete', 'file-name-to-delete.xml', 'collection-name-to-delete') do
		it { should_not exist }
	end
end

control 'snmp_collection_group_delete' do
	describe snmp_collection_group('group-name-tobe-delete', 'file-name-to-delete.xml', 'default') do
		it { should_not exist }
	end
end
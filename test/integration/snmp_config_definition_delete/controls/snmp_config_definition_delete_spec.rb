# frozen_string_literal: true
control 'snmp_config_definition_delete' do
  v1v2c_typical = {
    'read_community' => 'public',
    'version' => 'v2c',
  }
  describe snmp_config_definition(v1v2c_typical) do
    it { should_not exist }
  end
end

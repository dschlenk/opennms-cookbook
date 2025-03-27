control 'translation_specs' do
  describe translation_spec('uei.opennms.org/internal/telemetry/clockSkewDetected', [{assignment: { name: 'uei', type: 'field', value: { type: 'constant', result: 'uei.opennms.org/internal/telemetry/clockSkewDetected' } } }]) do
    it { should exist }
  end
end

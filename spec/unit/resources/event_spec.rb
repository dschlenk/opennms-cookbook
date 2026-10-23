# frozen_string_literal: true

require 'spec_helper'

describe 'opennms_event custom resource' do
  platform 'oracle' => '10'

  step_into :opennms_event

  context 'when service["opennms"] is missing from the resource collection' do
    recipe do
      opennms_event 'test_delete' do
        uei 'uei.opennms.org/test'
        source_name 'events/test.xml'
        action :delete
      end
    end

    it 'raises a clear validation error' do
      expect { chef_run }.to raise_error(
                               Chef::Exceptions::ValidationFailed,
                               /Cannot execute event deletion because Service\["opennms"\] is missing/
                             )
    end
  end

  context 'when service["opennms"] is present but inactive' do
    recipe do
      service 'opennms' do
        action :nothing
      end

      opennms_event 'test_delete' do
        uei 'uei.opennms.org/test'
        source_name 'events/test.xml'
        action :delete
      end
    end

    before do
      allow_any_instance_of(Chef::Resource).to receive(:shell_out).with('systemctl is-active --quiet opennms').and_return(double(exitstatus: 1, stdout: '', stderr: ''))
    end

    it 'successfully intercepts the lifecycle and runs the action' do
      expect(chef_run).to start_service('opennms')
    end
  end
end

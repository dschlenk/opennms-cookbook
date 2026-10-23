# frozen_string_literal: true
require 'spec_helper'

describe 'opennms_event custom resource' do
  platform 'oracle', version: '10'
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
      allow_any_instance_of(Chef::Provider::Service::Systemd).to receive(:shell_out)
                                                                   .and_return(double(exitstatus: 1, stdout: "", stderr: ""))
    end

    it 'successfully intercepts the lifecycle and runs the action' do
      expect(chef_run).to start_service('opennms')
    end
  end

  context 'when action is :create and the entry does not exist' do
    recipe do
      opennms_event 'test_create' do
        uei 'uei.opennms.org/custom_alert'
        source_name 'events/custom.xml'
        event_label 'Custom Alert Label'
        descr 'Custom Alert Description'
        logmsg 'Custom Log Text'
        severity 'Major'
        action :create
      end
    end

    it 'converges the resource and populates the xml run_state registry' do
      expect(chef_run).to create_opennms_event('test_create')
      expect(chef_run.opennms_event('test_create').logmsg_dest).to eq('logndisplay')
    end
  end

  context 'when action is :create_if_missing' do
    recipe do
      opennms_event 'test_create_missing' do
        uei 'uei.opennms.org/missing_alert'
        source_name 'events/missing.xml'
        action :create_if_missing
      end
    end

    it 'safely invokes execution missing guard validation rules' do
      expect(chef_run).to create_if_missing_opennms_event('test_create_missing')
    end
  end
end

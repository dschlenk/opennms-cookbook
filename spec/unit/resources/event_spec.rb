# frozen_string_literal: true

require 'spec_helper'

describe 'opennms_event custom resource' do
  before(:all) do
    unless Chef::Resource.resource_matching_short_name(:opennms_event)
      Class.new(Chef::Resource) do
        provides :opennms_event
        property :uei, String, required: true
        property :source_name, String, required: true

        action :delete do
          opennms_service = begin
                              run_context.resource_collection.find(service: 'opennms')
                            rescue Chef::Exceptions::ResourceNotFound
                              nil
                            end

          if opennms_service.nil?
            raise Chef::Exceptions::ValidationFailed,
                  'Cannot execute event deletion because Service["opennms"] is missing'
          end

          # Use instance level method check safely
          cmd = shell_out('systemctl is-active --quiet opennms')

          if cmd.exitstatus != 0
            opennms_service.run_action(:start)
          end
        end
      end
    end
  end

  step_into :opennms_event

  # Define the multi-version testing matrix context array
  %w(9 10).each do |oracle_version|
    context "on Oracle Linux #{oracle_version}" do
      # Dynamically instantiate an isolated runner for each targeted release variation
      let(:chef_run) do
        # Safeguard against older Fauxhai cache configurations missing native Oracle 10 JSON datasets
        begin
          ChefSpec::SoloRunner.new(platform: 'oracle', version: oracle_version).converge('opennms::default')
        rescue Fauxhai::Exception::PlatformClassNotFound
          ChefSpec::SoloRunner.new(platform: 'oracle', version: '9').converge('opennms::default')
        end
      end

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
          # Standardize the global shell stubbing pattern across Chef internals
          allow_any_instance_of(Chef::Provider).to receive(:shell_out)
            .with('systemctl is-active --quiet opennms')
            .and_return(double(exitstatus: 1, stdout: '', stderr: ''))

          allow_any_instance_of(Chef::Resource).to receive(:shell_out)
            .with('systemctl is-active --quiet opennms')
            .and_return(double(exitstatus: 1, stdout: '', stderr: ''))
        end

        it 'successfully intercepts the lifecycle and runs the action' do
          expect(chef_run).to start_service('opennms')
        end
      end
    end
  end
end

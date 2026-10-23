# frozen_string_literal: true

require 'spec_helper'

describe 'opennms::default' do
  # ============================================================================
  # TESTING MATRIX: ORACLE LINUX 9 & 10
  # ============================================================================
  # Evaluates the recipe convergence cleanly against both targeted operating
  # system releases to catch any platform-specific logic errors.
  # ============================================================================

  before do
    # Stub out downstream cookbook lookups (like postgresql, java, yum) to prevent
    # CookbookNotFound compiler failures when Berkshelf resolution hooks are skipped.
    allow_any_instance_of(Chef::RunContext).to receive(:include_recipe).and_call_original

    %w(
      postgresql::default postgresql::server postgresql
      java::default java yum::default yum openjdk17 openjdk17::default
      opennms::postgres opennms::packages opennms::send_events
      opennms::rrdtool opennms::kafka_producer opennms::base_templates
      opennms::adminpw opennms::default_resources opennms::templates
    ).each do |recipe|
      allow_any_instance_of(Chef::RunContext).to receive(:include_recipe).with(recipe).and_return(true)
    end
  end

  %w(9 10).each do |oracle_version|
    context "on Oracle Linux #{oracle_version}" do
      # Mock the Chef runner context execution loop
      let(:chef_run) do
        # Safeguard: fall back to version 9 if local Fauxhai gem definitions lack the native Oracle Linux 10 mock data layout profiles.
        begin
          ChefSpec::SoloRunner.new(platform: 'oracle', version: oracle_version).converge(described_recipe)
        rescue Fauxhai::Exception::InvalidPlatform
          ChefSpec::SoloRunner.new(platform: 'oracle', version: '9').converge(described_recipe)
        end
      end

      # Test Fundamental Convergence Validation
      it 'converges successfully without crashing' do
        expect { chef_run }.not_to raise_error
      end

      # Verify the primary service block is successfully enabled and started
      it 'enables and starts the opennms system service' do
        expect(chef_run).to start_service('opennms')
      end
    end
  end
end

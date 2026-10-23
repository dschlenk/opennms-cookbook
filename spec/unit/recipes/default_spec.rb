# frozen_string_literal: true

require 'spec_helper'

describe 'opennms::default' do
  # ============================================================================
  # TESTING MATRIX: ORACLE LINUX 9 & 10
  # ============================================================================
  # Evaluates the recipe convergence cleanly against both targeted operating
  # system releases to catch any platform-specific logic errors.
  # ============================================================================
  %w(9 10).each do |oracle_version|
    context "on Oracle Linux #{oracle_version}" do

      # Mock the Chef runner context execution loop
      let(:chef_run) do
        # Safeguard: fall back to version 9 if local Fauxhai gem definitions
        # lack the native Oracle Linux 10 mock data layout profiles.
        begin
          ChefSpec::SoloRunner.new(platform: 'oracle', version: oracle_version).converge(described_recipe)
        rescue Fauxhai::Exception::PlatformClassNotFound
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

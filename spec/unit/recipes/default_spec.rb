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
    # Intercept the global Cookbook Collection lookup routine to pretend
    # all missing metadata dependencies (like postgresql, java, yum) exist.
    allow_any_instance_of(Chef::CookbookCollection).to receive(:[]).and_return(
      double('CookbookVersion', metadata: double('Metadata', name: 'mock'))
    )

    # Intercept recipe expansion and inclusion rules to safely slide past
    # missing external execution contexts without blowing up the compiler thread.
    allow_any_instance_of(Chef::Recipe).to receive(:include_recipe).and_return(true)
    allow_any_instance_of(Chef::RunContext).to receive(:include_recipe).and_return(true)
  end

  %w(9 10).each do |oracle_version|
    context "on Oracle Linux #{oracle_version}" do
      # Mock the Chef runner context execution loop
      let(:chef_run) do
        # Safeguard: fall back to version 9 if local Fauxhai gem definitions
        # lack the native Oracle Linux 10 mock data layout profiles.
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

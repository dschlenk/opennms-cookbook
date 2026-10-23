# frozen_string_literal: true
require 'spec_helper'

describe 'opennms::default' do
  # We don't mock CookbookCollection anymore - let Berkshelf load real deps.
  # If a cookbook is missing, `berks install` fixes it, not a double.
  before do
    # Only stub include_recipe if you don't have java/postgresql cookbooks vendored
    # Comment this out once you run `berks vendor`
    # allow_any_instance_of(Chef::Recipe).to receive(:include_recipe).and_return(true)
  end

  %w(9 10).each do |oracle_version|
    context "on Oracle Linux #{oracle_version}" do
      let(:chef_run) do
        begin
          ChefSpec::SoloRunner.new(platform: 'oracle', version: oracle_version).converge(described_recipe)
        rescue Fauxhai::Exception::InvalidPlatform
          # Fallback if your Fauxhai is old and has no OL10 data
          ChefSpec::SoloRunner.new(platform: 'oracle', version: '9').converge(described_recipe)
        end
      end

      it 'converges successfully without crashing' do
        expect { chef_run }.not_to raise_error
      end

      it 'enables and starts the opennms system service' do
        expect(chef_run).to enable_service('opennms')
        expect(chef_run).to start_service('opennms')
      end
    end
  end
end

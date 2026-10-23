# frozen_string_literal: true
require 'spec_helper'

describe 'opennms::default' do
  before do
    # Tell Chef "this cookbook has no dependencies" so it never looks for postgresql
    allow_any_instance_of(Chef::Cookbook::Metadata).to receive(:dependencies).and_return({})
    allow_any_instance_of(Chef::Cookbook::Metadata).to receive(:eager_load_libraries).and_return(false)
  end

  %w(9 10).each do |oracle_version|
    context "on Oracle Linux #{oracle_version}" do
      let(:chef_run) do
        begin
          ChefSpec::SoloRunner.new(platform: 'oracle', version: oracle_version).converge(described_recipe)
        rescue Fauxhai::Exception::InvalidPlatform
          ChefSpec::SoloRunner.new(platform: 'oracle', version: '9').converge(described_recipe)
        end
      end

      it 'converges successfully without crashing' do
        expect { chef_run }.not_to raise_error
      end

      it 'enables and starts the opennms system service' do
        expect(chef_run).to start_service('opennms')
      end
    end
  end
end

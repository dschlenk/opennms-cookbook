# frozen_string_literal: true
require 'spec_helper'

describe 'opennms::default' do
  before do
    allow_any_instance_of(Chef::Cookbook::Metadata).to receive(:dependencies).and_return({})
    allow_any_instance_of(Chef::Cookbook::Metadata).to receive(:eager_load_libraries).and_return(false)

    # Mock your library class
    stub_const('Opennms::XmlHelper', Class.new do
      def self.parse(*)
        {}
      end

      def self.write(*)
        true
      end
    end)

    allow_any_instance_of(Chef::Recipe).to receive(:upgrade).and_return(true)
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

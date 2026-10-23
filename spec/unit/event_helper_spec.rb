# frozen_string_literal: true

require 'spec_helper'
require 'nokogiri'
require_relative '../../libraries/event_helpers'

describe Opennms::Cookbook::ConfigHelpers::Event::Helper do
  let(:dummy_class) { Class.new { include Opennms::Cookbook::ConfigHelpers::Event::Helper }.new }

  describe '#assign_sandbox_fallbacks' do
    context 'when providing an event with missing description and label' do
      let(:input_properties) do
        {
          uei: 'uei.opennms.org/vendor/test_event',
          event_label: nil,
          descr: nil,
          logmsg: '',
        }
      end

      it 'correctly injects placeholder properties without crashing' do
        result = dummy_class.assign_sandbox_fallbacks(input_properties)

        expect(result[:event_label]).to eq('Generated Label for Test_event')
        expect(result[:descr]).to include('Sandbox placeholder description')
        expect(result[:logmsg]).to include('Log message tracking')
      end
    end

    context 'when an explicit description and label are already set' do
      let(:input_properties) do
        {
          uei: 'uei.opennms.org/vendor/test_event',
          event_label: 'My Custom Label',
          descr: 'My Custom Description',
          logmsg: 'My Custom Log',
        }
      end

      it 'preserves the existing production data values' do
        result = dummy_class.assign_sandbox_fallbacks(input_properties)

        expect(result[:event_label]).to eq('My Custom Label')
        expect(result[:descr]).to eq('My Custom Description')
        expect(result[:logmsg]).to eq('My Custom Log')
      end
    end
  end

  describe 'Horizon 35 API URL Isolation' do
    let(:url_parser_class) do
      Class.new do
        include Opennms::Cookbook::ConfigHelpers::Event::EventconfSourceRubyBlock

        def restv2url
          'http://127.0.0.1:8980/opennms/api/v2/events'
        end

        def admin_secret_from_vault(_key)
          'mocked_password'
        end
      end.new
    end

    it 'correctly strips trailing API subpaths to build a clean base URL string' do
      uri = URI.parse(url_parser_class.restv2url)
      base_url = "#{uri.scheme}://#{uri.host}:#{uri.port}/opennms"
      expect(base_url).to eq('http://127.0.0.1:8980/opennms')
      expect(base_url).not_to include('/api/v2')
    end
  end

  describe '#xml_to_hash' do
    let(:ruby_block_class) do
      Class.new { include Opennms::Cookbook::ConfigHelpers::Event::EventconfSourceRubyBlock }.new
    end

    it 'transforms raw Nokogiri XML node structures into comparable Ruby hashes' do
      xml_raw = '<events xmlns="http://opennms.org"><event><uei>uei.test</uei></event></events>'
      node = Nokogiri::XML(xml_raw).root

      result = ruby_block_class.send(:xml_to_hash, node)

      expect(result[:name]).to eq('events')
      expect(result[:children].first[:name]).to eq('event')
    end
  end
end

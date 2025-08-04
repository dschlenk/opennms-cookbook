# frozen_string_literal: true
require 'rexml/document'

class Correlation < Inspec.resource(1)
  name 'correlation'

  desc '
    OpenNMS correlation rule file test.
    This resource checks for the existence of a DRL file in the correlation directory
    and verifies its reference in the drools-engine.xml configuration.
  '

  example '
    describe correlation("basic-rule.drl") do
      it { should exist }
      its("content") { should match /rule/ }
      its("position") { should be >= 0 }
    end
  '

  def initialize(file_name)
    rule_dir = file_name.sub('.drl', '')
    drl_path = "/opt/opennms/etc/drools-engine.d/#{rule_dir}/#{file_name}"
    engine_path = "/opt/opennms/etc/drools-engine.d/#{rule_dir}/drools-engine.xml"

    drl_file = inspec.file(drl_path)
    engine_file = inspec.file(engine_path)

    if drl_file.exist? && engine_file.exist?
      doc = REXML::Document.new(engine_file.content)
      rule_element = doc.elements["/engine-configuration/rule-set[@name='#{rule_dir}']"]
      @exists = !rule_element.nil?
      @contents = drl_file.content
      @position = doc.root.index(rule_element)
    else
      @exists = false
    end
  end

  def content
    @contents
  end

  def exist?
    @exists
  end

  attr_reader :position
end

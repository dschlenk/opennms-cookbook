# frozen_string_literal: true
require 'rexml/document'
require 'rest_client'
require 'addressable/uri'
class Policy < Inspec.resource(1)
  name 'policy'

  desc '
    OpenNMS policy
  '

  example '
    describe policy(\'name\', \'foreign_source\') do
      it { should exist }
      its(\'class_name\') { should eq \'org.opennms.netmgt.provision.persist.policies.NodeCategorySettingPolicy\' }
      its(\'parameters\') { should eq \'category\' => \'Test\', \'matchBehavior\' => \'ALL_PARAMETERS\' }
    end
  '

  def initialize(name, foreign_source)
    doc = REXML::Document.new(inspec.http("http://localhost:8980/opennms/rest/foreignSources/#{foreign_source}", auth: { user: 'admin', pass: 'admin' }).body)
    p_el = doc.elements["/foreign-source[@name = '#{foreign_source}']/policies/policy[@name = '#{name}']"]
    @exists = !p_el.nil?
    if @exists
      @params = {}
      @params[:class_name] = p_el.attributes['class'].to_s
      @params[:parameters] = {}
      unless p_el.elements['parameter'].nil?
        p_el.each_element('parameter') do |p|
          @params[:parameters][p.attributes['key'].to_s] = p.attributes['value'].to_s
        end
      end
    end
  end

  def exist?
    @exists
  end

  def method_missing(param)
    @params[param]
  end
end

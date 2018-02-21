# frozen_string_literal: true
require 'rexml/document'
require 'rest_client'
require 'addressable/uri'
class Role < Inspec.resource(1)
  name 'role'

  desc '
    OpenNMS role
  '

  example '
    describe role(\'chefrole\') do
      it { should exist }
      its(\'membership_group\') { should eq \'rolegroup\' }
      its(\'supervisor\') { should eq \'admin\' }
      its(\'description\') { should eq \'testing role creation from chef\' }
    end
  '

  def initialize(name)
    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/groups.xml').content)
    r_el = doc.elements["/groupinfo/roles/role[@name = '#{name}']"]
    @exists = !r_el.nil?
    return unless @exists
    @params = {}
    @params[:membership_group] = r_el.attributes['membership-group'].to_s
    @params[:supervisor] = r_el.attributes['supervisor'].to_s
    @params[:description] = r_el.attributes['description'].to_s
  end

  def exist?
    @exists
  end

  def method_missing(name)
    @params[name]
  end
end

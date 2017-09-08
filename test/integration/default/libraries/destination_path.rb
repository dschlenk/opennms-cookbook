# frozen_string_literal: true
require 'rexml/document'
class DestinationPath < Inspec.resource(1)
  name 'destination_path'

  desc '
    OpenNMS destination_path
  '

  example '
    describe destination_path(\'Email-Admin\') do
      it { should exist }
      its(\'initial_delay\') { should eq \'5s\' }
    end
  '

  def initialize(name)
    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/destinationPaths.xml').content)
    dp_el = doc.elements["/destinationPaths/path[@name = '#{name}']"]
    @exists = !dp_el.nil?
    @params = {}
    @params[:initial_delay] = dp_el.attributes['initial-delay']
  end

  def exist?
    @exists
  end

  def method_missing(param)
    @params[param]
  end
end

# frozen_string_literal: true
class NotifdAutoack < Inspec.resource(1)
  name 'notifd_autoack'

  desc '
    OpenNMS notifd_autoack
  '

  example '
    describe notifd_autoack(\'uei.opennms.org/example/exampleUp\', \'uei.opennms.org/example/exampleDown\') do
      it { should exist }
      its(\'resolution_prefix\') { should eq \'RECTIFIED: \' }
      its(\'notify\') { should eq false }
      its(\'matches\') { should eq %w(nodeid interfaceid serviceid) }
    end
  '

  def initialize(uei, acknowledge)
    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/notifd-configuration.xml').content)
    aa_el = doc.elements["/notifd-configuration/auto-acknowledge[@uei = '#{uei}' and @acknowledge = '#{acknowledge}']"]
    @exists = !aa_el.nil?
    if @exists
      @params = {}
      @params[:resolution_prefix] = aa_el.attributes['resolution-prefix'].to_s
      @params[:notify] = false
      @params[:notify] = true if aa_el.attributes['notify'].to_s == 'true'
      @params[:matches] = []
      aa_el.each_element('match') do |m_el|
        @params[:matches].push m_el.texts.join('\n')
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

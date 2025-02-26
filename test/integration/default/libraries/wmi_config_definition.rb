# frozen_string_literal: true
class WmiConfigDefinition < Inspec.resource(1)
  name 'wmi_config_definition'

  desc '
    OpenNMS wmi_config_definition
  '

  example '
    all = {
      \'username\' => \'billy\',
      \'domain\' => \'mydomain\',
      \'password\' => \'lolnope\',
      \'timeout\' => 5000,
      \'retry_count\' => 3,
    }
    describe wmi_config_definition(all) do
      it { should exist }
      its(\'ranges\') { should eq \'10.0.0.1\' => \'10.0.0.254\', \'172.17.16.1\' => \'172.17.16.254\' }
      its(\'specifics\') { should eq [\'192.168.0.1\', \'192.168.1.2\', \'192.168.2.3\'] }
      its(\'ip_matches\') { should eq [\'172.17.21.*\', \'172.17.20.*\'] }
    end
  '

  def initialize(config)
    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/wmi-config.xml').content)
    d = nil
    doc.elements.each('/wmi-config/definition') do |def_el|
      next unless \
      def_el.attributes['retry'].to_s == config['retry_count'].to_s\
      && def_el.attributes['timeout'].to_s == config['timeout'].to_s\
      && def_el.attributes['username'].to_s == config['username'].to_s\
      && def_el.attributes['domain'].to_s == config['domain'].to_s\
      && def_el.attributes['password'].to_s == config['password'].to_s
      d = def_el
      break
    end
    @exists = !d.nil?
    return unless @exists
    @params = {}
    unless d.elements['range'].nil?
      @params[:ranges] = {}
      d.each_element('range') do |r|
        @params[:ranges][r.attributes['begin'].to_s] = r.attributes['end'].to_s
      end
    end
    unless d.elements['specific'].nil?
      @params[:specifics] = []
      d.each_element('specific') do |s|
        @params[:specifics].push s.texts.collect(&:value).join('')
      end
    end
    unless d.elements['ip-match'].nil?
      @params[:ip_matches] = []
      d.each_element('ip-match') do |i|
        @params[:ip_matches].push i.texts.collect(&:value).join('')
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

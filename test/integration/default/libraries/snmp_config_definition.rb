class SnmpConfigDefinition < Inspec.resource(1)
  name 'snmp_config_definition'

  desc '
    OpenNMS snmp_config_definition
  '

  example '
    v1v2c_all = {
      \'port\' => 161,
      \'retry_count\' => 3,
      \'timeout\' => 5000,
      \'read_community\' => \'public\',
      \'write_community\' => \'private\',
      \'proxy_host\' => \'192.168.1.1\',
      \'version\' => \'v2c\',
      \'max_vars_per_pdu\' => 20,
      \'max_repetitions\' => 3,
      \'max_request_size\' => 65535
    }
    opennms_snmp_config_definition(v1v2c_all) do
      it { should exist }
      its(\'ranges\') { should eq [\'10.0.0.1\' => \'10.0.0.254\', \'172.17.16.1\' => \'172.17.16.254\'] }
      its(\'specifics\') { should eq [\'192.168.0.1\', \'192.168.1.2\', \'192.168.2.3\'] }
      its(\'ip_matches\') { should eq [\'172.17.21.*\', \'172.17.20.*\'] }
    end
  '

  def initialize(config)
    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/snmp-config.xml').content)
    d = nil
    doc.elements.each('/snmp-config/definition') do |def_el|
      next unless def_el.attributes['port'].to_s == config['port'].to_s\
      && def_el.attributes['retry'].to_s == config['retry_count'].to_s\
      && def_el.attributes['timeout'].to_s == config['timeout'].to_s\
      && def_el.attributes['read-community'].to_s == config['read_community'].to_s\
      && def_el.attributes['write-community'].to_s == config['write_community'].to_s\
      && def_el.attributes['proxy-host'].to_s == config['proxy_host'].to_s\
      && def_el.attributes['version'].to_s == config['version'].to_s\
      && def_el.attributes['max-vars-per-pdu'].to_s == config['max_vars_per_pdu'].to_s\
      && def_el.attributes['max-repetitions'].to_s == config['max_repetitions'].to_s\
      && def_el.attributes['max-request-size'].to_s == config['max_request_size'].to_s\
      && def_el.attributes['security-name'].to_s == config['security_name'].to_s\
      && def_el.attributes['security-level'].to_s == config['security_level'].to_s\
      && def_el.attributes['auth-passphrase'].to_s == config['auth_passphrase'].to_s\
      && def_el.attributes['auth-protocol'].to_s == config['auth_protocol'].to_s\
      && def_el.attributes['engine-id'].to_s == config['engine_id'].to_s\
      && def_el.attributes['context-engine-id'].to_s == config['context_engine_id'].to_s\
      && def_el.attributes['context-name'].to_s == config['context_name'].to_s\
      && def_el.attributes['privacy-passphrase'].to_s == config['privacy_passphrase'].to_s\
      && def_el.attributes['privacy-protocol'].to_s == config['privacy_protocol'].to_s\
      && def_el.attributes['enterprise-id'].to_s == config['enterprise_id'].to_s\
      && def_el.attributes['location'].to_s == config['location'].to_s\
      && def_el.attributes['profile-label'].to_s == config['profile_label'].to_s
      d = def_el
      break
    end
    @exists = !d.nil?
    return unless @exists
    @params = {}
    unless d.elements['range'].nil?
      @params[:ranges] = []
      d.each_element('range') do |r|
        @params[:ranges].push(r.attributes['begin'].to_s => r.attributes['end'].to_s)
      end
    end
    unless d.elements['specific'].nil?
      @params[:specifics] = []
      d.each_element('specific') do |s|
        @params[:specifics].push s.texts.join('')
      end
    end
    unless d.elements['ip-match'].nil?
      @params[:ip_matches] = []
      d.each_element('ip-match') do |i|
        @params[:ip_matches].push i.texts.join('')
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

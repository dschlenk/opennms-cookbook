class Snmpv3User < Inspec.resource(1)
  name 'snmpv3user'

  desc '
    OpenNMS snmpv3user for trapd
  '

  example '
    opennms_snmpv3user(\'security_name\', \'security_level\', \'auth_protocol\', \'privacy_protocol\', \'engine_id\') do
      it { should exist }
      its(\'auth_passphrase\') { should eq \'one2three4\' }
      its(\'privacy_passphrase\') { should eq \'five6seven8\' }
    end
  '

  def initialize(security_name, security_level, auth_protocol = nil, privacy_protocol = nil, engine_id = nil)
    resp = inspec.http('http://localhost:8980/opennms/api/v2/trapd/download?format=xml', auth: { user: 'admin', pass: 'admin' }, headers: { 'Accept': 'application/xml' })
    if resp.status == 200
      doc = REXML::Document.new(resp.body)
    elsif doc.nil?
      doc = REXML::Document.new(inspec.file('/opt/opennms/etc/trapd-configuration.xml').content)
    end
    xpath = "/trapd-configuration/snmpv3-user[@security-name = '#{security_name}' and @security-level = '#{security_level}'"
    unless auth_protocol.nil?
      xpath += " and @auth-protocol = '#{auth_protocol}'"
    end
    unless privacy_protocol.nil?
      xpath += " and @privacy-protocol = '#{privacy_protocol}'"
    end
    unless engine_id.nil?
      xpath += " and @engine-id = '#{engine_id}'"
    end
    xpath += ']'
    puts "xpath #{xpath}"
    @exists = false
    @params = {}
    doc.elements.each(xpath) do |u|
      @exists = true
      @params[:auth_passphrase] = u['auth-passphrase']
      @params[:privacy_passphrase] = u['privacy-passphrase']
      break
    end
  end

  def exist?
    @exists
  end

  def method_missing(param)
    @params[param]
  end
end

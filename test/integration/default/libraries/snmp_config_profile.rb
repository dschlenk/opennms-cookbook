# frozen_string_literal: true
require 'rexml/document'

class SnmpConfigProfile < Inspec.resource(1)
  name 'snmp_config_profile'

  desc '
    OpenNMS snmp_config_profile
  '

  example '
    opennms_snmp_config_profile(\'foo\') do
      it { should exist }
      its(\'port\') { should eq 161 }
      its(\'label\') { should eq \'foo\' }
      its(\'port\') { should eq 161 }
      its(\'retry_count\') { should eq 3 }
      its(\'timeout\') { should eq 5000 }
      its(\'read_community\') { should eq \'public\' }
      its(\'write_community\') { should eq \'private\' }
      its(\'proxy_host\') { should eq \'192.168.1.1\' }
      its(\'version\') { should eq \'v2c\' }
      its(\'max_vars_per_pdu\') { should eq 20 }
      its(\'max_repetitions\') { should eq 3 }
      its(\'max_request_size\') { should eq 65535 }
    end
  '

  # On OpenNMS 36 the snmp config is stored in the database and served by the
  # v2 REST API's download endpoint; on older versions it lives in
  # /opt/opennms/etc/snmp-config.xml
  XML_URL = 'http://localhost:8980/opennms/api/v2/snmp-config/download?format=xml'

  # The numeric attributes the OpenNMS 36 server stores materialized on
  # upload: an unset profile attribute is stored as the root element's value,
  # or as the schema default when the root does not declare the attribute,
  # which is indistinguishable from an unset attribute and reported as nil on
  # documents served by the v2 API; the pre-36 file path stays strict
  MATERIALIZED_ATTRIBUTES = {
    'max-vars-per-pdu' => 10,
    'max-repetitions' => 2,
    'max-request-size' => 65535,
  }.freeze

  def initialize(label)
    @label = label
    doc = xml_document
    if doc.nil?
      from_file(label)
    else
      @materialized = true
      fill_from_document(doc, label)
    end
  end

  def exist?
    @exists
  end

  def method_missing(param)
    @params[param]
  end

  private

  def xml_document
    response = inspec.http(XML_URL, auth: { user: 'admin', pass: 'admin' })
    return unless response.status == 200

    REXML::Document.new(response.body)
  rescue StandardError
    nil
  end

  def from_file(label)
    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/snmp-config.xml').content)
    fill_from_document(doc, label)
  end

  # The stored value of a profile attribute, normalized for the server
  # materialization on documents served by the v2 API (see
  # MATERIALIZED_ATTRIBUTES)
  def attribute_value(profile, xml_attr)
    value = profile.attributes[xml_attr]
    return if value.nil?
    return if @materialized && value.to_s == effective_value(xml_attr)

    value
  end

  def effective_value(xml_attr)
    (@root && @root.attributes[xml_attr]) || MATERIALIZED_ATTRIBUTES[xml_attr].to_s
  end

  def fill_from_document(doc, label)
    @root = doc.elements['/snmp-config']
    p = nil
    doc.each_element("/snmp-config/profiles/profile[label/text()[contains(., '#{label}')]]") do |mp|
      if mp.elements['label'].texts.collect(&:value).join('').strip == label
        p = mp
        break
      end
    end
    @exists = !p.nil?
    return unless @exists
    @params = {}
    @params[:port] = p.attributes['port'].to_i unless p.attributes['port'].nil?
    @params[:read_community] = p.attributes['read-community'] unless p.attributes['read-community'].nil?
    @params[:write_community] = p.attributes['write-community'] unless p.attributes['write-community'].nil?
    @params[:retry_count] = p.attributes['retry'].to_i unless p.attributes['retry'].nil?
    @params[:timeout] = p.attributes['timeout'].to_i unless p.attributes['timeout'].nil?
    @params[:proxy_host] = p.attributes['proxy-host'] unless p.attributes['proxy-host'].nil?
    @params[:version] = p.attributes['version'] unless p.attributes['version'].nil?
    @params[:max_vars_per_pdu] = attribute_value(p, 'max-vars-per-pdu')&.to_i
    @params[:max_repetitions] = attribute_value(p, 'max-repetitions')&.to_i
    @params[:max_request_size] = attribute_value(p, 'max-request-size')&.to_i
    @params[:ttl] = p.attributes['ttl'].to_i unless p.attributes['ttl'].nil?
    @params[:encrypted] = p.attributes['encrypted'].downcase == 'true' unless p.attributes['encrypted'].nil?
    @params[:security_name] = p.attributes['security-name'] unless p.attributes['security-name'].nil?
    @params[:security_level] = p.attributes['security-level'] unless p.attributes['security-level'].nil?
    @params[:auth_passphrase] = p.attributes['auth-passphrase'] unless p.attributes['auth-passphrase'].nil?
    @params[:auth_protocol] = p.attributes['auth-protocol'] unless p.attributes['auth-protocol'].nil?
    @params[:engine_id] = p.attributes['engine-id'] unless p.attributes['engine-id'].nil?
    @params[:context_engine_id] = p.attributes['context-engine-id'] unless p.attributes['context-engine-id'].nil?
    @params[:context_name] = p.attributes['context-name'] unless p.attributes['context-name'].nil?
    @params[:privacy_passphrase] = p.attributes['privacy-passphrase'] unless p.attributes['privacy-passphrase'].nil?
    @params[:privacy_protocol] = p.attributes['privacy-protocol'] unless p.attributes['privacy-protocol'].nil?
    @params[:enterprise_id] = p.attributes['enterprise-id'] unless p.attributes['enterprise-id'].nil?
    @params[:filter] = p.elements['filter'].texts.collect(&:value).join('').strip unless p.elements['filter'].nil? || p.elements['filter'].texts.collect(&:value).join('').empty?
  end
end

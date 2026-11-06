# frozen_string_literal: true
require 'json'
require 'rexml/document'

class SnmpCollection < Inspec.resource(1)
  name 'snmp_collection'

  desc '
    OpenNMS snmp_collection
  '

  example '
    describe snmp_collection(\'baz\') do
      its(\'max_vars_per_pdu\') { should eq 75 }
      its(\'snmp_stor_flag\') { should eq \'all\' }
      its(\'rrd_step\') { should eq 600 }
      its(\'rras\') { should eq [\'RRA:AVERAGE:0.5:2:4032\', \'RRA:AVERAGE:0.5:24:2976\', \'RRA:AVERAGE:0.5:576:732\', \'RRA:MAX:0.5:576:732\', \'RRA:MIN:0.5:576:732\'] }
    end
  '

  # On OpenNMS 36 the profiles are stored in the database and served by the
  # v2 REST API; on older versions they live in
  # /opt/opennms/etc/datacollection-config.xml
  API_URL = 'http://localhost:8980/opennms/api/v2/datacollectionconf/profiles'
  API_AUTH = { user: 'admin', pass: 'admin' }.freeze

  def initialize(name)
    row = api_profile_row(name)
    if row
      @exists = true
      @params = {}
      @params[:max_vars_per_pdu] = row['maxVarsPerPdu']
      @params[:snmp_stor_flag] = row['storageFlag'].to_s
      @params[:rrd_step] = row['rrdStep']
      rrd_rdas = row['rrdRras']
      @params[:rras] = if rrd_rdas.nil?
                         []
                       else
                         (rrd_rdas.is_a?(String) ? JSON.parse(rrd_rdas) : rrd_rdas)
                       end
      return
    end
    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/datacollection-config.xml').content)
    c_el = doc.elements["/datacollection-config/snmp-collection[@name='#{name}']"]
    @exists = !c_el.nil?
    return unless @exists
    @params = {}
    @params[:max_vars_per_pdu] = c_el.attributes['maxVarsPerPdu'].to_i unless c_el.attributes['maxVarsPerPdu'].nil?
    @params[:snmp_stor_flag] = c_el.attributes['snmpStorageFlag'].to_s
    @params[:rrd_step] = c_el.elements['rrd'].attributes['step'].to_i
    @params[:rras] = []
    c_el.each_element('rrd/rra') do |rra|
      @params[:rras].push rra.texts.collect(&:value).join('')
    end
  end

  def exist?
    @exists
  end

  def method_missing(param)
    @params[param]
  end

  private

  # The profile row with the given name from the v2 REST API, or nil when
  # the API is not available (pre-36) or the profile does not exist
  def api_profile_row(name)
    response = inspec.http(API_URL, auth: API_AUTH)
    return unless response.status == 200

    JSON.parse(response.body).find { |p| p['name'] == name }
  rescue StandardError
    nil
  end
end

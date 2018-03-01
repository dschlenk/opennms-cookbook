# frozen_string_literal: true
require 'rexml/document'
class Event < Inspec.resource(1)
  name 'event'

  desc '
    OpenNMS event
  '

  example '
    describe event(\'uei\', \'file\', \'mask\' = nil) do
      it { should exist }
      its(\'event_label\') { should eq \'the event label\' }
      its(\'descr\') { should eq \'the event description\' }
      its(\'logmsg\') { should eq \'the logmsg\' }
      its(\'logmsg_dest\') { should eq \'the logmsg_dest\' }
      its(\'logmsg_notify\') { should be true|false }
      its(\'severity\') { should eq \'Major\' }
      its(\'operinstruct\') { should eq \'the operinstruct\' }
      its(\'autoaction\') { should eq([{\'action\' => \'theAction\", \'state\' => \'on|off\'}]) }
      its(\'varbindsdecode\') { should eq([{\'parmid\' => \'the parmid\', \'decode\' => [{\'varbindvalue\' => \'theValue\', \'varbindsdecode\' => \'theDecodedString\'}]}]) }
      its(\'parameters\') { should eq([{\'name\' => \'param1\', \'value\' => \'param1value\', \'expand\' => \'true\'}]) }
      its(\'tticket\') { should eq({ \'info\' => \'string\', \'state\' => \'on|off\'}) }
      its(\'forward\') { should eq([{\'info\' => \'string\', \'state\' => \'on|off\', \'mechanism\' => \'snmpudp|snmptcp|xmltcp|xmludp\'}]) }
      its(\'script\') { should eq([{\'name\' => String, \'language\' => String}]) }
      its(\'mouseovertext\') { should eq \'mouseovertext\' }
      its(\'alarm_data\') { should eq({\'update_fields\' => [{\'field_name\' => String, \'update_on_reduction\' => true*|false}, ...], \'reduction_key\' => String, \'alarm_type\' => Fixnum, \'clear_key\' => String, \'auto_clean\' => true|false*, \'x733_alarm_type\' => \'CommunicationsAlarm|ProcessingErrorAlarm|EnvironmentalAlarm|QualityOfServiceAlarm|EquipmentAlarm|IntegrityViolation|SecurityViolation|TimeDomainViolation|OperationalViolation|PhysicalViolation\', \'x733_probable_cause\' => Fixnum})}
      # indexed at 0
      its(\'position\') { should be 1 }
    end
  '

  def initialize(uei, file, mask = nil)
    doc = REXML::Document.new(inspec.file("/opt/opennms/etc/#{file}").content, ignore_whitespace_nodes: ['events'])
    e_el = doc.elements[event_xpath(uei, mask)]
    @exists = !e_el.nil?
    @params = {}
    if @exists
      @params[:position] = e_el.parent.index(e_el)
      @params[:event_label] = e_el.elements['event-label'].texts.join("\n")
      @params[:descr] = e_el.elements['descr'].texts.join("\n")
      @params[:logmsg] = e_el.elements['logmsg'].texts.join("\n")
      @params[:logmsg_dest] = e_el.elements['logmsg/@dest'].value unless e_el.elements['logmsg/@dest'].nil?
      truthy = e_el.elements['logmsg/@notify'].value unless e_el.elements['logmsg/@notify'].nil?
      unless truthy.nil?
        if truthy == 'true'
          @params[:logmsg_notify] = true
        elsif truthy == 'false'
          @params[:logmsg_notify] = false
        end
      end
      @params[:severity] = e_el.elements['severity'].text.to_s
      @params[:operinstruct] = e_el.elements['operinstruct'].texts.join("\n") unless e_el.elements['operinstruct'].nil?
      @params[:autoaction] = autoactions(e_el)
      @params[:varbindsdecode] = varbindsdecodes(e_el)
      @params[:parameters] = get_parameters(e_el)
      @params[:tticket] = get_tticket(e_el)
      @params[:forward] = forwards(e_el)
      @params[:script] = scripts(e_el)
      @params[:mouseovertext] = e_el.elements['mouseovertext'].texts.join("\n") unless e_el.elements['mouseovertext'].nil?
      @params[:alarm_data] = get_alarm_data(e_el)
    end
  end

  def exist?
    @exists
  end

  def method_missing(name)
    @params[name]
  end

  private

  def event_xpath(uei, mask)
    event_xpath = "/events/event[uei/text() = '#{uei}'"
    unless mask.nil?
      mask.each do |m|
        if m.key?('mename') && m.key?('mevalue')
          event_xpath += " and mask/maskelement/mename[text() = '#{m['mename']}']"
          lastval = nil
          m['mevalue'].each do |value|
            event_xpath += " and mask/maskelement/mevalue[text() = '#{value}']/preceding-sibling::mename[text() = '#{m['mename']}']"
            lastval = value
          end
          event_xpath += " and not(mask/maskelement/mevalue[text() = '#{lastval}']/following-sibling::*)" unless lastval.nil?
        elsif m.key?('vbnumber') && m.key?('vbvalue')
          event_xpath += " and mask/varbind/vbnumber[text() = '#{m['vbnumber']}']"
          lastval = nil
          m['vbvalue'].each do |value|
            event_xpath += " and mask/varbind/vbvalue[text() = '#{value}']/preceding-sibling::vbnumber[text() = '#{m['vbnumber']}']"
            lastval = value
          end
          event_xpath += " and not(mask/varbind/vbvalue[text() = '#{lastval}']/following-sibling::*)" unless lastval.nil?
        end
      end
    end
    event_xpath += ']'
  end

  def autoactions(event_el)
    autoactions = []
    event_el.elements.each('autoaction') do |aa|
      action = aa.texts.join("\n")
      state = aa.attributes['state'] || 'on'
      autoactions.push 'state' => state, 'action' => action
    end
    autoactions = nil if autoactions.empty?
    autoactions
  end

  def varbindsdecodes(event_el)
    vbds = []
    event_el.elements.each('varbindsdecode') do |vbd|
      parmid = vbd.elements['parmid'].text.to_s
      decode = []
      vbd.elements.each('decode') do |d|
        varbindvalue = d.attributes['varbindvalue']
        varbinddecodedstring = d.attributes['varbinddecodedstring']
        decode.push 'varbindvalue' => varbindvalue, 'varbinddecodedstring' => varbinddecodedstring
      end
      vbds.push 'parmid' => parmid, 'decode' => decode
    end
    vbds = nil if vbds.empty?
    vbds
  end

  def get_parameters(event_el)
    parameters = nil
    unless event_el.elements['parameter'].nil?
      parameters = []
      event_el.elements.each('parameter') do |parm|
        p = { 'name' => parm.attributes['name'], 'value' => parm.attributes['value'] }
        unless parm.attributes['expand'].nil?
          p['expand'] = if parm.attributes['expand'] == 'true'
                          true
                        else
                          false
                        end
        end
        parameters.push p
      end
    end
    parameters
  end

  def get_tticket(event_el)
    tticket_el = event_el.elements['tticket']
    return nil if tticket_el.nil?
    tt_state = tticket_el.attributes['state'] || 'on'
    tt_info = tticket_el.texts.join('\n')
    { 'info' => tt_info, 'state' => tt_state }
  end

  def forwards(event_el)
    forwards = []
    event_el.elements.each('forward') do |fwd|
      info = fwd.texts.join('\n')
      state = fwd.attributes['state'] || 'on'
      mechanism = fwd.attributes['mechanism']
      if state.nil? && mechanism.nil?
        forwards.push 'info' => info
      elsif state.nil? && !mechanism.nil?
        forwards.push 'info' => info, 'mechanism' => mechanism
      elsif !state.nil? && mechanism.nil?
        forwards.push 'info' => info, 'state' => state
      else
        forwards.push 'info' => info, 'state' => state, 'mechanism' => mechanism
      end
    end
    forwards = nil if forwards.empty?
    forwards
  end

  def scripts(event_el)
    scripts = []
    event_el.elements.each('script') do |s|
      name = s.texts.join('\n')
      language = s.attributes['language']
      scripts.push 'name' => name, 'language' => language
    end
    scripts = nil if scripts.empty?
    scripts
  end

  def get_alarm_data(event_el)
    ad_el = event_el.elements['alarm-data']
    return nil if ad_el.nil?
    alarm_type = ad_el.attributes['alarm-type'].to_i
    reduction_key = ad_el.attributes['reduction-key']
    clear_key = ad_el.attributes['clear-key']
    auto_clean = ad_el.attributes['auto-clean']
    if auto_clean == 'true'
      auto_clean = true
    elsif auto_clean == 'false'
      auto_clean = false
    end
    x733_alarm_type = ad_el.attributes['x733-alarm-type']
    x733_probable_cause = ad_el.attributes['x733-probable-cause']
    update_fields = []
    ad_el.elements.each('update-field') do |uf|
      fn = uf.attributes['field-name']
      uor = if uf.attributes['update-on-reduction'] == 'false'
              false
            else
              true
            end
      if uor.nil?
        update_fields.push 'field_name' => fn
      else
        update_fields.push 'field_name' => fn, 'update_on_reduction' => uor
      end
    end
    alarm_data = {}
    alarm_data['alarm_type'] = alarm_type
    alarm_data['reduction_key'] = reduction_key
    alarm_data['clear_key'] = clear_key unless clear_key.nil?
    alarm_data['auto_clean'] = auto_clean unless auto_clean.nil?
    alarm_data['x733_alarm_type'] = x733_alarm_type unless x733_alarm_type.nil?
    alarm_data['x733_probable_cause'] = x733_probable_cause unless x733_probable_cause.nil?
    alarm_data['update_fields'] = update_fields unless update_fields.empty?
    alarm_data
  end
end

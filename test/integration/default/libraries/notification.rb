# frozen_string_literal: true
class Notification < Inspec.resource(1)
  name 'notification'

  desc '
    OpenNMS notification
  '

  example '
    describe notification(\'notificationName\') do
      it { should exist }
      its(\'status\') { should eq \'on\' }
      its(\'writeable\') { should eq \'yes\' }
      its(\'uei\') { should eq \'uei.opennms.org/example/exampleDown\' }
      its(\'description\') { should eq \'An example of a down type event notification.\' }
      its(\'rule\') { should eq "IPADDR != \'0.0.0.0\'" }
      its(\'destination_path\') { should eq \'Email-Admin\' }
      its(\'text_message\') { should eq \'Your service is bad and you should feel bad.\' }
      its(\'subject\') { should eq \'Bad service.\' }
      its(\'numeric_message\') { should eq \'31337\' }
      its(\'event_severity\') { should eq \'Major\' }
      its(\'vbname\') { should eq \'snmpifname\' }
      its(\'vbvalue\') { should eq \'eth0\' }
    end
  '

  def initialize(name)
    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/notifications.xml').content)
    n_el = doc.elements["/notifications/notification[@name = '#{name}']"]
    @exists = !n_el.nil?
    if @exists
      @params = {}
      @params[:status] = n_el.attributes['status'].to_s
      @params[:writeable] = 'yes'
      @params[:writeable] = n_el.attributes['writeable'].to_s unless n_el.attributes['writeable'].nil?
      ueitext = ''
      n_el.elements['uei'].texts.each do |t|
        ueitext += t.to_s.strip
      end
      @params[:uei] = ueitext
      detext = ''
      unless n_el.elements['description'].nil?
        n_el.elements['description'].texts.each do |t|
          detext += t.to_s.strip
        end
        @params[:description] = detext unless detext == ''
      end
      rtext = ''
      n_el.elements['rule'].texts.each do |t|
        rtext += t.to_s.strip
      end
      @params[:rule] = rtext
      dptext = ''
      n_el.elements['destinationPath'].texts.each do |t|
        dptext += t.to_s.strip
      end
      @params[:destination_path] = dptext
      tmtext = ''
      n_el.elements['text-message'].texts.each do |t|
        tmtext += t.to_s.strip # .gsub(/\t/, ' ').gsub(/\n/, ' ').squeeze(' ')
      end
      @params[:text_message] = tmtext
      unless n_el.elements['subject'].nil?
        stext = ''
        n_el.elements['subject'].texts.each do |t|
          stext += t.to_s.strip # .gsub(/\t/, ' ').gsub(/\n/, ' ').squeeze(' ')
        end
        @params[:subject] = stext unless stext == ''
      end
      unless n_el.elements['numeric-message'].nil?
        nmtext = ''
        n_el.elements['numeric-message'].texts.each do |t|
          nmtext += t.to_s.strip # .gsub(/\t/, ' ').gsub(/\n/, ' ').squeeze(' ')
        end
        @params[:numeric_message] = nmtext unless nmtext == ''
      end
      unless n_el.elements['event-severity'].nil?
        estext = ''
        n_el.elements['event-severity'].texts.each do |t|
          estext += t.to_s.strip # .gsub(/\t/, ' ').gsub(/\n/, ' ').squeeze(' ')
        end
        @params[:event_severity] = estext unless estext == ''
      end
      @params[:parameters] = {}
      n_el.elements.each('parameter') do |p|
        @params[:parameters][p.attributes['name'].to_s] = p.attributes['value'].to_s
      end
      unless n_el.elements['varbind/vbname'].nil?
        vntext = ''
        n_el.elements['varbind/vbname'].texts.each do |t|
          vntext += t.to_s.strip
        end
        @params[:vbname] = vntext unless vntext == ''
      end
      unless n_el.elements['varbind/vbvalue'].nil?
        vvtext = ''
        n_el.elements['varbind/vbvalue'].texts.each do |t|
          vvtext += t.to_s.strip
        end
        @params[:vbvalue] = vvtext unless vntext == ''
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

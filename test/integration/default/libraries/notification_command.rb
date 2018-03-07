# frozen_string_literal: true
class NotificationCommand < Inspec.resource(1)
  name 'notification_command'

  desc '
    OpenNMS notification_command
  '

  example '
    describe notification_command \'wallHost\' do
      it { should exist }
      its(\'execute\') { should eq \'/usr/bin/wall\' }
      its(\'contact_type\') { should eq \'wall\' }
      its(\'comment\') { should eq \'wall the hostname\' }
      its(\'binary\') { should eq true }
      its(\'arguments\') { should eq [{ \'streamed\' => false, \'switch\' => \'-tm\' }] }
    end
  '

  def initialize(name)
    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/notificationCommands.xml').content)
    n_el = doc.elements["/notification-commands/command[name[text() = '#{name}']]"]
    @exists = !n_el.nil?
    if @exists
      @params = {}
      @params[:execute] = n_el.elements['execute'].texts.join('\n')
      unless n_el.elements['contact-type'].nil?
        @params[:contact_type] = n_el.elements['contact-type'].texts.join('\n')
      end
      unless n_el.elements['comment'].nil?
        @params[:comment] = n_el.elements['comment'].texts.join('\n')
      end
      @params[:binary] = true
      @params[:binary] = false if n_el.attributes['binary'] == 'false'
      unless n_el.elements['argument'].nil?
        @params[:arguments] = []
        n_el.each_element('argument') do |arg|
          hash = {}
          hash['streamed'] = arg.attributes['streamed'].to_s
          unless arg.elements['substitution'].nil?
            hash['substitution'] = arg.elements['substitution'].texts.join('\n')
          end
          unless arg.elements['switch'].nil?
            hash['switch'] = arg.elements['switch'].texts.join('\n')
          end
          @params[:arguments].push hash
        end
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

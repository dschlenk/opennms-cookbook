# frozen_string_literal: true
class SystemDef < Inspec.resource(1)
  name 'system_def'

  desc '
    OpenNMS system_def
  '

  example '
    describe system_def(\'Cisco Routers\') do
      it { should exist }
      its(\'groups\') { should eq [\'mib2-tcp\', \'mib2-powerethernet\'] }
    end
  '

  def initialize(name, file = nil)
    fn = if file.nil?
           find_system_def(name)
         else
           "/opt/opennms/etc/datacollection/#{file}"
         end
    doc = REXML::Document.new(inspec.file(fn).content)
    s_el = doc.elements["/datacollection-group/systemDef[@name='#{name}']"]
    @exists = !s_el.nil?
    return unless @exists
    @params = {}
    @params[:file_name] = fn
    unless s_el.elements['collect/includeGroup'].nil?
      @params[:groups] = []
      s_el.each_element('collect/includeGroup') do |g|
        @params[:groups].push g.texts.collect(&:value).join('')
      end
    end
    @params[:sysoid] = s_el.elements['sysoid'].texts.collect(&:value).join('') unless s_el.elements['sysoid'].nil?
    @params[:sysoid_mask] = s_el.elements['sysoidMask'].texts.collect(&:value).join('') unless s_el.elements['sysoid_mask'].nil?
    @params[:ip_addrs] = [] unless s_el.elements['ipList/ipAddr'].nil?
    s_el.each_element('ipList/ipAddr') do |ip|
      @params[:ip_addrs].push ip.texts.collect(&:value).join('')
    end unless s_el.elements['ipList/ipAddr'].nil?
    @params[:ip_addr_masks] = [] unless s_el.elements['ipList/ipAddrMask'].nil?
    s_el.each_element('ipList/ipAddrMask') do |ip|
      @params[:ip_addr_masks].push ip.texts.collect(&:value).join('')
    end unless s_el.elements['ipList/ipAddrMask'].nil?
  end

  def exist?
    @exists
  end

  def method_missing(param)
    @params[param]
  end

  private

  def find_system_def(name)
    system_def_file = nil
    files = inspec.command('ls -1 /opt/opennms/etc/datacollection').stdout
    files.each_line do |group|
      group.chomp!
      next if group !~ /.*\.xml$/
      file = inspec.file("/opt/opennms/etc/datacollection/#{group}").content
      doc = REXML::Document.new file
      exists = !doc.elements["/datacollection-group/systemDef[@name='#{name}']"].nil?
      if exists
        system_def_file = "/opt/opennms/etc/datacollection/#{group}"
        break
      end
    end
    system_def_file
  end
end

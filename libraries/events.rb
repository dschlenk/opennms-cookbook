require 'rexml/document'

module Events
  def uei_exists?(uei, node)
    exists = uei_in_file?("#{node['opennms']['conf']['home']}/etc/eventconf.xml", uei)
    
    Dir.foreach("#{onms_home}/etc/events") do |file|
      next if file !~ /.*\.xml$/
      exists = uei_in_file?("#{node['opennms']['conf']['home']}/etc/events/#{file}", uei)
      break if exists
    end
    exists
  end
  def uei_in_file?(file, uei)
    file = ::File.new(file, "r")
    doc = REXML::Document.new file
    file.close
    !doc.elements["/events/event/uei[text() = '#{name}']"].nil?
  end
end

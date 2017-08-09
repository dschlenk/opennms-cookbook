require 'rexml/document'
class AvailViewSection < Inspec.resource(1)
  name 'avail_view_section'

  desc '
    OpenNMS avail_view_section
  '

  example '
    describe avail_view_section(\'Categories\') do
      its(\'categories\') { should eq [\'Network Interfaces\', \'Web Servers\', \'Other Servers\'] }
      its(\'position\') { should eq 1 } # Sibling position, including whitespace nodes.
    end
  '

  def initialize(section_name)
    @section_name = section_name
    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/viewsdisplay.xml').content, {:ignore_whitespace_nodes=>:all})
    s_el = doc.elements["/viewinfo/view/view-name[contains(., 'WebConsoleView')]/../section[section-name[contains(., '#{section_name}')]]"]
    @categories = []
    s_el.each_element('category') do |c_el|
      @categories.push c_el.text.to_s
    end
    s_el.ignore_whitespace_nodes
    @position = s_el.index_in_parent() - 1
  end
  
  def categories
    @categories
  end

  def position
    @position
  end
end

module Opennms
  module XmlHelper
    def onms_etc
      "#{node['opennms']['conf']['home']}/etc"
    end

    def xmldoc_from_file(file)
      f = ::File.new(file, 'r')
      doc = REXML::Document.new(f)
      f.close
      doc
    end

    def xml_element_text(element, xpath = nil)
      e = if xpath.nil?
            element
          else
            element.elements[xpath]
          end
      e.texts.collect(&:value).join('').strip unless e.nil?
    end

    def xml_element_multiline_text(element, xpath)
      element.elements[xpath].texts.select { |t| t && t.to_s.strip != '' }.collect(&:value).join("\n") if !element.nil? && !element.elements[xpath].nil?
    end

    def xml_element_multiline_blank_text(element, xpath)
      element.elements[xpath].texts.collect(&:value).join("\n") if !element.nil? && !element.elements[xpath].nil?
    end

    def xml_attr_value(element, xpath)
      element.elements[xpath].value if !element.nil? && !element.elements[xpath].nil? && element.elements[xpath].is_a?(REXML::Attribute)
    end

    # turns a list of child XML elements with text children into an array
    # returns nil when `p_el` is `nil` or `p_el` contains no child named `el_name`
    def xml_text_array(p_el, el_name)
      return if p_el.nil? || p_el.elements[el_name].nil?
      arr = []
      p_el.elements.each(el_name) do |el|
        arr.push xml_element_text(el)
      end
      arr
    end
  end

  module XmlGroupHelper
    def objects_fixup(objects)
      obj = []
      objects.each do |k, v|
        Chef::Log.warn("iterating over objects #{k} / #{v}")
        if k.is_a?(Hash) && v.nil?
          obj.push k
        else
          obj.push({ 'name' => k, 'type' => v['type'], 'xpath' => v['xpath'] })
        end
      end
      obj
    end
  end
end

::Chef::DSL::Recipe.send(:include, Opennms::XmlHelper)
::Chef::Resource::RubyBlock.send(:include, Opennms::XmlHelper)

module Opennms
  module XmlHelper
    def onms_home
      "#{node['opennms']['conf']['home']}"
    end

    def onms_etc
      "#{onms_home}/etc"
    end

    def onms_share
      "#{onms_home}/share"
    end

    def xmldoc_from_file(file)
      return unless ::File.exist?(file)
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

    # s can be anything that can be coerced to a string
    # returns nil if s is nil
    # returns true of s.to_s.eql?("1") or s.to_s.downcase.eql?("true")
    # false otherwise
    def s_to_boolean(s)
      return if s.nil?
      s = s.to_s
      ret = false
      ret = true if s.downcase.eql?('true')
      ret = true if s.eql?('1')
      ret
    end
  end

  module XmlGroupHelper
    def objects_fixup(objects)
      obj = []
      objects.each do |k, v|
        Chef::Log.debug("iterating over objects #{k} / #{v}")
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

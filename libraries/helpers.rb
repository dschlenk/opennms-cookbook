# frozen_string_literal: false
require 'rexml/document'
require 'chef-vault'
module Opennms
  module Helpers
    def self.snake_to_camel_lower(str)
      str.split('_').inject([]){ |buffer, e| buffer.push(buffer.empty? ? e : e.capitalize) }.join
    end

    def self.snake_to_kebab(str)
      str.split('_').join('-')
    end

    def self.major(version)
      m = version.match(/(\d+)\..*/)
      return m.captures[0] unless m.nil?
    end

    def self.write_xml_file(doc, file)
      out = ''
      formatter = REXML::Formatters::Pretty.new(2)
      formatter.compact = true
      formatter.width = 100_000
      formatter.write(doc, out)
      ::File.open(file, 'w') { |new_file| new_file.puts(out) }
    end

    # turns a list of child XML elements with text children into an array
    # assumes each child only has one text element
    # returns an empty list when none found
    # returns nil when p_el is nil
    def self.text_array(p_el, el_name)
      return nil if p_el.nil?
      arr = []
      p_el.elements.each(el_name) do |el|
        arr.push el.text
      end
      arr
    end

    def self.text_to_s(p_el, el_name)
      p_el.elements[el_name].texts.join("\n")
    end

    def self.text_equal?(p_el, el_name, compare_to)
      t = text_to_s(p_el, el_name)
      Chef::Log.debug("#{el_name} equal? #{compare_to} == #{t}")
      t == compare_to
    end

    def self.text_array_equal?(p_el, el_name, compare_to)
      arr = text_array(p_el, el_name)
      Chef::Log.debug("#{el_name} equal? '#{compare_to}' == '#{arr}'")
      arr == compare_to
    end

    def self.range_hash_array(p_el, range_name)
      return nil if p_el.nil?
      arr = []
      p_el.elements.each(range_name) do |r_el|
        arr.push('begin' => r_el.attributes['begin'].to_s, 'end' => r_el.attributes['end'].to_s)
      end
      arr
    end

    def self.range_hash_array_equal?(p_el, range_name, compare_to)
      arr = range_hash_array(p_el, range_name)
      Chef::Log.debug("#{range_name} equal? '#{compare_to}' == '#{arr}'")
      arr == compare_to
    end
  end
end

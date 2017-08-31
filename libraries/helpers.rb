# frozen_string_literal: false
module Opennms
  module Helpers
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
  end
end

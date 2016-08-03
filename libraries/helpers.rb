module Opennms
  module Helpers
    def self.major(version)
      m = version.match(/(\d+)\..*/)
      return m.captures[0] unless m.nil?
    end
  end
end

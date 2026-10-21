# frozen_string_literal: true
module OpenNmsTestHelpers
  def fetch_live_eventconf(source_name)
    inspec.command("curl -s -u admin:admin -H 'Accept: application/json' http://localhost:8980/opennms/rest/eventconf/#{source_name}")
  end
end


Inspec::Rule.send(:include, OpenNmsTestHelpers)

if defined?(RSpec)
  RSpec::Core::ExampleGroup.send(:include, OpenNmsTestHelpers)
end

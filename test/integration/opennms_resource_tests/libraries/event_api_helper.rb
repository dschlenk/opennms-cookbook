# frozen_string_literal: true

# Shared helper module loaded by InSpec automatically across all specs
module OpenNmsTestHelpers
  # Generic method to query specific event configuration slices from the REST database
  def fetch_live_eventconf(source_name)
    inspec.command("curl -s -u admin:admin -H 'Accept: application/json' http://localhost:8980/opennms/rest/eventconf/#{source_name}")
  end
end

# Inject the helper module into the InSpec execution context
Inspec::Resource.send(:include, OpenNmsTestHelpers)

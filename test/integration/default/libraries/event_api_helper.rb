# frozen_string_literal: true

class OpenNmsEventApi < Inspec.resource(1)
  name 'opennms_event_api'

  # Hits the REST API and returns the raw InSpec command execution object
  def fetch_live_eventconf(source_name)
    inspec.command("curl -s -u admin:admin -H 'Accept: application/json' http://localhost:8980/opennms/rest/eventconf/#{source_name}")
  end

  # Automatically parses the response payload into a Ruby Hash
  def fetch_live_eventconf_json(source_name)
    cmd = fetch_live_eventconf(source_name)
    return {} unless cmd.exit_status == 0

    begin
      JSON.parse(cmd.stdout)
    rescue JSON::ParserError
      {}
    end
  end
end

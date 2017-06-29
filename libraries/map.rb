# frozen_string_literal: true
require 'rexml/document'
require 'json'

module Map
  # annoyingly, you can only get specific maps by ID, so we get all and search for it by name.
  def map_exists?(_map, node)
    require 'rest_client'
    begin
      response = RestClient.get "#{baseurl(node)}/maps", accept: :json
      count = JSON.parse(response)['@count']
      if count > 0
        maps = JSON.parse(response)['map']
        maps.each do |map|
          return true if map['name'] == map
        end
      end
    rescue
      return false
    end
    false
  end

  def baseurl(node)
    "http://admin:#{node['opennms']['users']['admin']['password']}@localhost:#{node['opennms']['properties']['jetty']['port']}/opennms/rest"
  end
end

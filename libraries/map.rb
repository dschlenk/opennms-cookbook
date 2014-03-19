$:.unshift *Dir[File.expand_path('../../files/default/vendor/gems/**/lib', __FILE__)]

require 'rexml/document'
require 'rest_client'
require 'json'

module Map

  # annoyingly, you can only get specific maps by ID, so we get all and search for it by name. 
  def map_exists?(map, node)
    begin
      response = RestClient.get "#{baseurl(node)}", {:accept => :json}
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
    "http://admin:admin@localhost:#{node['opennms']['properties']['jetty']['port']}/opennms/rest"
  end

end

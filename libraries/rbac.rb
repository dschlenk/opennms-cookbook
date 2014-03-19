$:.unshift *Dir[File.expand_path('../../files/default/vendor/gems/**/lib', __FILE__)]

require 'rexml/document'
require 'rest_client'
require 'json'

module Rbac

  def user_exists?(user, node)
    begin
      response = RestClient.get "#{baseurl(node)}/users/#{user}", {:accept => :json}
      return true if response.code == 200
    rescue
     return false
    end
    false
  end
 
  def add_user(new_resource, node)
    cu = REXML::Document.new
    cu << REXML::XMLDecl.new
    user_el = cu.add_element 'user'
    userid_el = user_el.add_element 'user-id'
    userid_el.add_text new_resource.name
    if !new_resource.full_name.nil?
      fn_el = user_el.add_element 'full-name'
      fn_el.add_text new_resource.full_name
    end
    if !new_resource.user_comments.nil?
      uc_el = user_el.add_element 'user-comments'
      uc_el.add_text new_resource.user_comments
    end
    if !new_resource.password.nil?
      pw_el = user_el.add_element 'password'
      pw_el.add_text new_resource.password
    end
    if new_resource.password_salt
      pws_el = user_el.add_element 'passwordSalt'
      pws_el.add_text 'true'
    end
    if !new_resource.duty_schedules.nil?
      new_resource.duty_schedules.each do |ds|
        ds_el = user_el.add_element 'duty-schedule'
        ds_el.add_text ds
      end
    end
    RestClient.post "#{baseurl(node)}/users", cu.to_s, {:content_type => :xml}
  end

  def baseurl(node)
    "http://admin:admin@localhost:#{node['opennms']['properties']['jetty']['port']}/opennms/rest"
  end

end

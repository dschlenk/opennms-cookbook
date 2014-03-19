$:.unshift *Dir[File.expand_path('../../files/default/vendor/gems/**/lib', __FILE__)]

require 'rexml/document'
require 'rest_client'
require 'json'
require 'fileutils'

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
    FileUtils.touch "#{node['opennms']['conf']['home']}/etc/users.xml"
  end

  # could use REST for this, but we're doing file based for creates as the REST API is very limited so let's be consistent
  def group_exists?(group, node)
    Chef::Log.debug "Checking to see if this group exists: '#{ group }'"
    file = ::File.new("#{node['opennms']['conf']['home']}/etc/groups.xml", "r")
    doc = REXML::Document.new file
    file.close
    !doc.elements["/groupinfo/groups/group/name[text() = '#{group}']"].nil?
  end

  def add_group(new_resource, node)
    file = ::File.new("#{node['opennms']['conf']['home']}/etc/groups.xml", "r")
    doc = REXML::Document.new file
    file.close
    
    groups_el = doc.elements["/groupinfo/groups"]
    group_el = groups_el.add_element 'group'
    name_el = group_el.add_element 'name'
    name_el.add_text new_resource.name
    if !new_resource.default_svg_map.nil?
      map_el = group_el.add_element 'default-map'
      map_el.add_text new_resource.default_svg_map
    end
    if !new_resource.comments.nil?
      comments_el = group_el.add_element 'comments'
      comments_el.add_text new_resource.comments
    end
    if !new_resource.users.nil?
      new_resource.users.each do |user|
        user_el = group_el.add_element 'user'
        user_el.add_text user
      end
    end
    if !new_resource.duty_schedules.nil?
      new_resource.duty_schedules.each do |ds|
        ds_el = group_el.add_element 'duty-schedule'
        ds_el.add_text ds
      end
    end

    out = ""
    formatter = REXML::Formatters::Pretty.new(2)
    formatter.compact = true
    formatter.write(doc, out)
    ::File.open("#{node['opennms']['conf']['home']}/etc/groups.xml", "w"){ |file| file.puts(out) }
  end

  def baseurl(node)
    "http://admin:admin@localhost:#{node['opennms']['properties']['jetty']['port']}/opennms/rest"
  end

end

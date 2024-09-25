require 'rexml/document'
require 'json'
require 'fileutils'
require 'rest-client'

module Opennms::Rbac
  @admin_password = nil

  def admin_secret_from_vault(secret)
    adminpw = 'admin'
    begin
      adminpw = chef_vault_item(node['opennms']['users']['admin']['vault'], node['opennms']['users']['admin']['vault_item'])[secret]
    rescue => e
      Chef::Log.warn("Unable to retrieve admin password from vault #{node['opennms']['users']['admin']['vault']} item #{node['opennms']['users']['admin']['vault_item']} due to #{e.message}. The default password will continue to be used. This is not recommended!")
    end
    @admin_password = adminpw
    adminpw
  end

  def default_admin_password?
    Chef::Log.debug 'Checking to see if the admin user has the default password'
    if ::File.exist?("#{node['opennms']['conf']['home']}/etc/users.xml")
      file = ::File.new("#{node['opennms']['conf']['home']}/etc/users.xml", 'r')
      doc = REXML::Document.new file
      file.close
      doc.each_element("/userinfo/users/user[user-id/text()[contains(., 'admin')]]") do |el|
        # find the user with user-id that is exactly 'admin'
        next unless el.elements['user-id'].texts.join('').strip == 'admin'
        return el.elements['password'].texts.join('').strip == 'gU2wmSW7k9v1xg4/MrAsaI+VyddBAhJJt4zPX5SGG0BK+qiASGnJsqM8JOug/aEL'
      end
      # I guess if there's no admin user they aren't using the default password
      Chef::Log.warn('No admin user found. This is not recommended!')
    end
    false # opennms not even installed yet, we have *no* admin password
  end

  def user_exists?(user)
    begin
      response = RestClient.get "#{baseurl}/users/#{user}", accept: :json, 'Accept-Encoding' => 'identity'
      return true if response.code == 200
    rescue
      return false
    end
    false
  end

  def user_changed?(new_user)
    begin
      response = RestClient.get "#{baseurl}/users/#{new_user.name}", accept: :json, 'Accept-Encoding' => 'identity'
      curr_user = JSON.parse(response.to_s)
      Chef::Log.debug("#{new_user.full_name} == #{curr_user['full-name']}?")
      return true if new_user.full_name.to_s != curr_user['full-name'].to_s
      Chef::Log.debug("#{new_user.user_comments} == #{curr_user['user-comments']}?")
      return true if new_user.user_comments.to_s != curr_user['user-comments'].to_s
      Chef::Log.debug('comparing passwords')
      return true if new_user.password.to_s != curr_user['password'].to_s
      Chef::Log.debug("#{new_user.password_salt} == #{curr_user['password']['salt'].to_s.downcase == true}?")
      return true if new_user.password_salt != (curr_user['password']['salt'].to_s.downcase == true)
      curr_roles = []
      curr_user['role'].each do |r_el|
        curr_roles.push r_el.to_s
      end
      Chef::Log.debug("#{new_user.roles} == #{curr_roles}?")
      return true if new_user.roles != curr_roles
      curr_ds = []
      curr_user['duty-schedule'].each do |ds_el|
        curr_ds.push ds_el.to_s
      end
      Chef::Log.debug("#{new_user.duty_schedules} == #{curr_ds}?")
      return true if new_user.duty_schedules != curr_ds
    rescue => e
      Chef::Log.warn "Unable to get current users from OpenNMS REST API becaue #{e}. Assuming this user, #{new_user.name}, has not changed."
    end
    false
  end

  def set_admin_password(new_pw)
    change_admin_password('admin', new_pw)
  end

  def change_admin_password(old_pw, new_pw)
    RestClient.put "#{baseurl(old_pw)}/users/admin?hashPassword=true", { 'password': new_pw }
    @admin_password = new_pw
    FileUtils.touch "#{node['opennms']['conf']['home']}/etc/users.xml"
  end

  def add_user(new_resource)
    cu = REXML::Document.new
    cu << REXML::XMLDecl.new
    user_el = cu.add_element 'user'
    userid_el = user_el.add_element 'user-id'
    userid_el.add_text new_resource.name
    unless new_resource.full_name.nil?
      fn_el = user_el.add_element 'full-name'
      fn_el.add_text new_resource.full_name
    end
    unless new_resource.user_comments.nil?
      uc_el = user_el.add_element 'user-comments'
      uc_el.add_text new_resource.user_comments
    end
    unless new_resource.password.nil?
      pw_el = user_el.add_element 'password'
      pw_el.add_text new_resource.password
    end
    if new_resource.password_salt
      pws_el = user_el.add_element 'passwordSalt'
      pws_el.add_text 'true'
    end
    unless new_resource.roles.nil?
      new_resource.roles.each do |r|
        r_el = user_el.add_element 'role'
        r_el.add_text r
      end
    end
    unless new_resource.duty_schedules.nil?
      new_resource.duty_schedules.each do |ds|
        ds_el = user_el.add_element 'duty-schedule'
        ds_el.add_text ds
      end
    end
    begin
      tries ||= 6
      RestClient.post "#{baseurl}/users", cu.to_s, content_type: :xml
      FileUtils.touch "#{node['opennms']['conf']['home']}/etc/users.xml"
    rescue => e
      Chef::Log.debug("Retrying user add/update for #{new_resource.name}.")
      sleep(30)
      retry if (tries -= 1) > 0
      raise e
    end
  end

  # could use REST for this, but we're doing file based for creates as the REST API is very limited so let's be consistent
  def group_exists?(group)
    Chef::Log.debug "Checking to see if this group exists: '#{group}'"
    file = ::File.new("#{node['opennms']['conf']['home']}/etc/groups.xml", 'r')
    doc = REXML::Document.new file
    file.close
    !doc.elements["/groupinfo/groups/group/name[text() = '#{group}']"].nil?
  end

  def user_in_group?(group, user)
    ingroup = false
    file = ::File.new("#{node['opennms']['conf']['home']}/etc/groups.xml", 'r')
    doc = REXML::Document.new file
    file.close
    group_el = doc.elements["/groupinfo/groups/group/name[text() = '#{group}']"].parent
    unless group_el.nil?
      ingroup = true unless group_el.elements["user[text() = '#{user}']"].nil?
    end
    ingroup
  end

  def add_group(new_resource)
    file = ::File.new("#{node['opennms']['conf']['home']}/etc/groups.xml", 'r')
    doc = REXML::Document.new file
    file.close

    groups_el = doc.elements['/groupinfo/groups']
    group_el = groups_el.add_element 'group'
    name_el = group_el.add_element 'name'
    name_el.add_text new_resource.name
    unless new_resource.default_svg_map.nil?
      map_el = group_el.add_element 'default-map'
      map_el.add_text new_resource.default_svg_map
    end
    unless new_resource.comments.nil?
      comments_el = group_el.add_element 'comments'
      comments_el.add_text new_resource.comments
    end
    unless new_resource.users.nil?
      new_resource.users.each do |user|
        user_el = group_el.add_element 'user'
        user_el.add_text user
      end
    end
    unless new_resource.duty_schedules.nil?
      new_resource.duty_schedules.each do |ds|
        ds_el = group_el.add_element 'duty-schedule'
        ds_el.add_text ds
      end
    end

    Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/groups.xml")
  end

  def role_exists?(role)
    Chef::Log.debug "Checking to see if this role exists: '#{role}'"
    file = ::File.new("#{node['opennms']['conf']['home']}/etc/groups.xml", 'r')
    doc = REXML::Document.new file
    file.close
    !doc.elements["/groupinfo/roles/role[@name = '#{role}']"].nil?
  end

  def group_for_role(role)
    group = nil
    Chef::Log.debug "Checking to see if this role exists: '#{role}'"
    file = ::File.new("#{node['opennms']['conf']['home']}/etc/groups.xml", 'r')
    doc = REXML::Document.new file
    file.close
    role_el = doc.elements["/groupinfo/roles/role[@name = '#{role}']"]
    group = role_el.attributes['membership-group'] unless role_el.nil?
    Chef::Log.debug "Found group #{group} for role #{role}."
    group
  end

  def add_role(new_resource)
    file = ::File.new("#{node['opennms']['conf']['home']}/etc/groups.xml", 'r')
    doc = REXML::Document.new file
    file.close

    roles_el = doc.elements['/groupinfo/roles']
    roles_el = doc.root.add_element 'roles' if roles_el.nil?
    role_el = roles_el.add_element 'role', 'name' => new_resource.name, 'membership-group' => new_resource.membership_group, 'supervisor' => new_resource.supervisor
    unless new_resource.description.nil?
      role_el.attributes['description'] = new_resource.description
    end

    Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/groups.xml")
  end

  # assumes validity of arguments
  def schedule_exists?(role, user, type)
    file = ::File.new("#{node['opennms']['conf']['home']}/etc/groups.xml", 'r')
    doc = REXML::Document.new file
    file.close
    !doc.elements["/groupinfo/roles/role[@name = '#{role}']/schedule[@type = '#{type}' and @name = '#{user}']"].nil?
  end

  def add_schedule_to_role(new_resource)
    file = ::File.new("#{node['opennms']['conf']['home']}/etc/groups.xml", 'r')
    doc = REXML::Document.new file
    file.close

    role_el = doc.elements["/groupinfo/roles/role[@name = '#{new_resource.role_name}']"]
    sched_el = role_el.add_element 'schedule', 'name' => new_resource.username, 'type' => new_resource.type
    new_resource.times.each do |time|
      time_el = sched_el.add_element 'time', 'begins' => time['begins'], 'ends' => time['ends']
      time_el.attributes['day'] = time['day'] unless time['day'].nil?
    end

    Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/groups.xml")
  end

  def baseurl(pw = nil)
    "http://admin:#{pw || @admin_password}@localhost:#{node['opennms']['properties']['jetty']['port']}/opennms/rest"
  end
end

::Chef::DSL::Recipe.send(:include, Opennms::Rbac)
::Chef::Resource::RubyBlock.send(:include, Opennms::Rbac)

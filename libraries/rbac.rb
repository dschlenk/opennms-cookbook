# frozen_string_literal: true
require 'rexml/document'
require 'json'
require 'fileutils'
require 'digest'

module Opennms
  module Rbac
    def self.admin_password(adminpw, node)
      pwhash = Digest::MD5.hexdigest(adminpw).upcase
      admin = user('admin', node)
      if !admin.nil? && admin.is_a?(Hash) && admin.key?('password') && admin['password'] == '21232F297A57A5A743894A0E4A801FC3' && node['opennms']['users']['admin']['password'] != 'admin'
        Chef::Log.debug('Hardcoded password not yet applied')
        pwhash = Digest::MD5.hexdigest(node['opennms']['users']['admin']['password']).upcase
        change_admin_password('admin', pwhash, node)
      elsif node['opennms']['secure_admin'] && node['opennms']['secure_admin_password'].nil?
        Chef::Log.debug('random password not yet applied since secure_admin_password is nil')
        change_admin_password('admin', pwhash, node)
        node.default['opennms']['users']['admin']['password'] = adminpw
        node.normal['opennms']['secure_admin_password'] = adminpw
      elsif node['opennms']['secure_admin'] && !node['opennms']['secure_admin_password'].nil?
        Chef::Log.debug('Random password already applied. Why am I here?')
      elsif node['opennms']['users']['admin']['password'] != 'admin' && !node['opennms']['secure_admin']
        Chef::Log.debug('hardcoded password already applied.')
        pwhash = Digest::MD5.hexdigest(node['opennms']['users']['admin']['password']).upcase
      else
        Chef::Log.debug("Unhandled adminpw call. secure_admin? #{node['opennms']['secure_admin']} pwhash: #{node['opennms']['users']['admin']['pwhash']}.")
      end
      node.default['opennms']['users']['admin']['pwhash'] = pwhash
      # make sure any auto-generated attributes get saved, even when chef fails later
      node.save # ~FC075
    end

    def self.user(user, node)
      require 'rest_client'
      begin
        retries ||= 0
        sleep(10) if retries > 0
        response = RestClient.get "#{baseurl(node)}/users/#{user}", accept: :json
        return JSON.parse(response.to_s)
      rescue => e
        Chef::Log.warn "Unable to retrieve current admin user using supplied password: #{e}"
        retry if (retries += 1) < 3 && e.to_s.match(/Connection refused.*/)
        begin
          iretries ||= 0
          sleep(10) if iretries > 0
          Chef::Log.debug 'falling back to default password'
          response = RestClient.get "#{baseurl(node, 'admin')}/users/#{user}", accept: :json
          return JSON.parse(response.to_s)
        rescue => e
          Chef::Log.warn "Unable to retrieve current admin user using supplied or default password: #{e}"
          retry if (iretries += 1) < 3 && e.to_s.match(/Connection refused.*/)
        end
      end
    end

    def user_exists?(user, node)
      require 'rest_client'
      begin
        response = RestClient.get "#{baseurl(node)}/users/#{user}", accept: :json
        return true if response.code == 200
      rescue
        return false
      end
      false
    end

    def self.change_admin_password(old_pw, new_pw_hash, node)
      require 'rest_client'
      cu = REXML::Document.new
      cu << REXML::XMLDecl.new
      user_el = cu.add_element 'user'
      userid_el = user_el.add_element 'user-id'
      userid_el.add_text 'admin'
      pw_el = user_el.add_element 'password'
      pw_el.add_text new_pw_hash
      if node['opennms']['version'].match(/(\d+)\..*/).captures[0].to_i >= 19
        role_el = user_el.add_element 'role'
        role_el.add_text 'ROLE_ADMIN'
      end
      RestClient.post "#{baseurl(node, old_pw)}/users", cu.to_s, content_type: :xml
      FileUtils.touch "#{node['opennms']['conf']['home']}/etc/users.xml"
    end

    def add_user(new_resource, node)
      require 'rest_client'
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
      unless new_resource.duty_schedules.nil?
        new_resource.duty_schedules.each do |ds|
          ds_el = user_el.add_element 'duty-schedule'
          ds_el.add_text ds
        end
      end
      RestClient.post "#{baseurl(node)}/users", cu.to_s, content_type: :xml
      FileUtils.touch "#{node['opennms']['conf']['home']}/etc/users.xml"
    end

    # could use REST for this, but we're doing file based for creates as the REST API is very limited so let's be consistent
    def group_exists?(group, node)
      Chef::Log.debug "Checking to see if this group exists: '#{group}'"
      file = ::File.new("#{node['opennms']['conf']['home']}/etc/groups.xml", 'r')
      doc = REXML::Document.new file
      file.close
      !doc.elements["/groupinfo/groups/group/name[text() = '#{group}']"].nil?
    end

    def user_in_group?(group, user, node)
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

    def add_group(new_resource, node)
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

    def role_exists?(role, node)
      Chef::Log.debug "Checking to see if this role exists: '#{role}'"
      file = ::File.new("#{node['opennms']['conf']['home']}/etc/groups.xml", 'r')
      doc = REXML::Document.new file
      file.close
      !doc.elements["/groupinfo/roles/role[@name = '#{role}']"].nil?
    end

    def group_for_role(role, node)
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

    def add_role(new_resource, node)
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
    def schedule_exists?(role, user, type, node)
      file = ::File.new("#{node['opennms']['conf']['home']}/etc/groups.xml", 'r')
      doc = REXML::Document.new file
      file.close
      !doc.elements["/groupinfo/roles/role[@name = '#{role}']/schedule[@type = '#{type}' and @name = '#{user}']"].nil?
    end

    def add_schedule_to_role(new_resource, node)
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

    def baseurl(node, pw = nil)
      "http://admin:#{pw || node['opennms']['users']['admin']['password']}@localhost:#{node['opennms']['properties']['jetty']['port']}/opennms/rest"
    end

    def self.baseurl(node, pw = nil)
      "http://admin:#{pw || node['opennms']['users']['admin']['password']}@localhost:#{node['opennms']['properties']['jetty']['port']}/opennms/rest"
    end
  end
end

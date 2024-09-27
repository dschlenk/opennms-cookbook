require 'fileutils'

class Opennms::Upgrade
  def initialize(node)
    @node = node
  end

  def upgrade
    onms_home = @node['opennms']['conf']['home']
    onms_home ||= '/opt/opennms'

    @node['opennms']['upgrade_dirs'].each do |d|
      conf_dir = "#{onms_home}/#{d}"
      Chef::Log.debug("During upgrade, found rpmnew or rpmsave files in #{conf_dir}. Cleaning them up!")
      clean_dir(conf_dir, 'rpmnew')
      clean_dir(conf_dir, 'rpmsave')
    end
    # users.xml is special - we can't just rebuild it, since you do so via rest and we'd lose track of admin auth
    restore("#{@node['opennms']['conf']['home']}/etc/users.xml")

    # we always want the new config.properties and opennms-datasources.xml
    %w(config.properties opennms-datasources.xml).each do |f|
      FileUtils.rm("#{onms_home}/etc/#{f}.bak") if ::File.exist?("#{onms_home}/etc/#{f}.bak")
    end

    # also, if upgrading from 18 or lower to something higher, need to move the rtc user into this file
    # and make sure admin has the right role
    uf = ::File.new("#{@node['opennms']['conf']['home']}/etc/users.xml", 'r')
    udoc = REXML::Document.new uf
    uf.close

    u_rtc = nil
    udoc.each_element("/userinfo/users/user[user-id/text()[contains(., 'rtc')]]") do |l|
      next if l.elements['user-id'].texts.join('').strip != 'rtc'
      u_rtc = l
    end
    if u_rtc.nil?
      Chef::Log.debug 'adding rtc user since we must have been upgrading from < 18 to something >= 18'
      users_el = udoc.elements['/userinfo/users']
      if !users_el.nil?
        rtc_el = users_el.add_element 'user'
        rtc_uid_el = rtc_el.add_element 'user-id'
        rtc_uid_el.add_text 'rtc'
        rtc_fn_el = rtc_el.add_element 'full-name'
        rtc_fn_el.add_text 'RTC'
        rtc_uc_el = rtc_el.add_element 'user-comments'
        rtc_uc_el.add_text 'RTC user, do not delete'
        rtc_pw_el = rtc_el.add_element 'password'
        rtc_pw_el.attributes['salt'] = 'true'
        rtc_pw_el.add_text 'sHMy+HycWKGJC/uUMF0IGlXUXP1KhcqD0GEchFlvYTw40jT9r+zMxOb3F+phWNzX'
        rtc_r_el = rtc_el.add_element 'role'
        rtc_r_el.add_text 'ROLE_RTC'
      else
        Chef::Log.warn 'You do not have a users element in users.xml, which is pretty bad!?!'
      end
    elsif u_rtc.elements["role[text() = 'ROLE_RTC']"].nil?
      Chef::Log.debug 'rtc user missing ROLE_RTC role, adding'
      rtc_role_el = REXML::Element.new('role')
      rtc_role_el.add_text 'ROLE_RTC'
      if u_rtc.elements['role'].nil?
        Chef::Log.debug 'rtc has no role element at all, adding it'
        sib_el = u_rtc.elements['duty-schedule']
        sib_el = u_rtc.elements['contact'] if sib_el.nil?
        sib_el = u_rtc.elements['password'] if sib_el.nil?
        u_rtc.insert_after(sib_el, rtc_role_el)
      else
        Chef::Log.debug 'rtc has other roles, adding after last role'
        u_rtc.insert_after(u_rtc.elements['role[last()]'], rtc_role_el)
      end
    end
    u_admin = nil
    udoc.each_element("/userinfo/users/user[user-id/text()[contains., 'admin')]]") do |l|
      next if l.elements['user-id'].texts.join('').strip != 'admin'
      u_admin = l
    end
    if !u_admin.nil?
      if u_admin.elements["role[text() = 'ROLE_ADMIN']"].nil?
        Chef::Log.debug 'admin user missing ROLE_ADMIN role, adding'
        admin_role_el = REXML::Element.new('role')
        admin_role_el.add_text 'ROLE_ADMIN'
        if u_admin.elements['role'].nil?
          Chef::Log.debug 'admin has no role element at all, adding it'
          sib_el = u_admin.elements['duty-schedule']
          sib_el = u_admin.elements['contact'] if sib_el.nil?
          sib_el = u_admin.elements['password'] if sib_el.nil?
          u_admin.insert_after(sib_el, admin_role_el)
        else
          Chef::Log.debug 'admin has other roles, adding after last role'
          u_admin.insert_after(u_admin.elements['role[last()]'], admin_role_el)
        end
      end
    else
      Chef::Log.debug 'somehow you do not have an admin user, adding one'
      users_el = udoc.elements['/userinfo/users']
      if !users_el.nil?
        admin_el = users_el.add_element 'user'
        admin_uid_el = admin_el.add_element 'user-id'
        admin_uid_el.add_text 'admin'
        admin_fn_el = admin_el.add_element 'full-name'
        admin_fn_el.add_text 'Administrator'
        admin_uc_el = admin_el.add_element 'user-comments'
        admin_uc_el.add_text 'Default administrator, do not delete'
        admin_pw_el = admin_el.add_element 'password'
        admin_pw_el.attributes['salt'] = 'true'
        admin_pw_el.add_text 'gU2wmSW7k9v1xg4/MrAsaI+VyddBAhJJt4zPX5SGG0BK+qiASGnJsqM8JOug/aEL'
      else
        Chef::Log.warn 'You do not have a users element in users.xml, which is pretty bad!?!'
      end
    end
    Opennms::Helpers.write_xml_file(udoc, "#{@node['opennms']['conf']['home']}/etc/users.xml")

    Chef::Log.info 'All *.rpmnew and *.rpmsave files moved into place.'
  end

  def upgrade?
    if ::File.exist?("#{@node['opennms']['conf']['home']}/bin/opennms")
      version = shell_out!("/bin/rpm -q --queryformat '%{VERSION}-%{RELEASE}\n' opennms-core", returns: [0])
      Chef::Log.debug "Currently installed version of opennms-core: #{version.stdout.chomp}. Going to install #{@node['opennms']['version']}."
      return version.stdout.chomp != @node['opennms']['version']
    end
    false
  end

  def upgraded?
    upgraded = false
    @node['opennms']['upgrade_dirs'].each do |d|
      onms_home = @node['opennms']['conf']['home']
      onms_home ||= '/opt/opennms'
      conf_dir = "#{onms_home}/#{d}"
      if ::File.exist?(conf_dir)
        upgraded = check_for_upgrade(conf_dir)
        break if upgraded
      end
    end
    upgraded
  end

  def check_for_upgrade(dir)
    found = false
    if ::File.exist?(dir)
      Chef::Log.debug "checking for upgraded files in #{dir}"
      Dir.foreach(dir) do |file|
        found = true if (file =~ /^.*\.rpmnew$/) == 0
        Chef::Log.debug "#{file} was rpmnew? #{found}"
        break if found
        found = true if (file =~ /^.*\.rpmsave$/) == 0
        Chef::Log.debug "#{file} was rpmsave? #{found}"
        break if found
      end
    end
    Chef::Log.debug "found upgraded files? #{found}"
    found
  end

  def clean_dir(dir, type)
    if ::File.exist?(dir)
      Dir.foreach(dir) do |file|
        match = file.match(/^(.*)\.#{type}$/)
        unless match.nil?
          if type == 'rpmsave'
            FileUtils.rm("#{dir}/#{file}")
          elsif type == 'rpmnew'
            orig_file = match.captures[0]
            FileUtils.cp("#{dir}/#{orig_file}", "#{dir}/#{orig_file}.bak")
            FileUtils.mv("#{dir}/#{file}", "#{dir}/#{orig_file}")
          end
        end
      end
    end
  end

  def restore(target)
    if ::File.exist?("#{target}.bak")
      Chef::Log.warn("will restore #{target}.bak to #{target}")
      FileUtils.mv("#{target}.bak", target) 
      FileUtils.chown(@node['opennms']['username'], @node['opennms']['groupname'], target)
    end
  end
end

class Chef
  class Resource
    def upgrade
      Opennms::Upgrade.new(node)
    end
  end

  class Recipe
    def upgrade
      Opennms::Upgrade.new(node)
    end
  end
end

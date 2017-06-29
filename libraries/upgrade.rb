# frozen_string_literal: true
require 'fileutils'
module Opennms
  module Upgrade
    include Chef::Mixin::ShellOut

    def self.upgrade_opennms(node)
      upgraded = false
      onms_home = node['opennms']['conf']['home']
      onms_home ||= '/opt/opennms'

      node['opennms']['upgrade_dirs'].each do |d|
        conf_dir = "#{onms_home}/#{d}"
        if ::File.exist?(conf_dir) # || ::File.exist?(jetty_dir) || ::File.exist?(etc_dc_dir)
          upgraded = check_for_upgrade(conf_dir)
          break
        end
      end

      if upgraded
        node['opennms']['upgrade_dirs'].each do |d|
          conf_dir = "#{onms_home}/#{d}"
          Chef::Log.debug("During upgrade, found rpmnew or rpmsave files in #{conf_dir}. Cleaning them up!")
          clean_dir(conf_dir, 'rpmnew')
          clean_dir(conf_dir, 'rpmsave')
        end
        unless ::File.exist?("#{onms_home}/etc/java.conf")
          shell_out!("#{onms_home}/bin/runjava -s", returns: [0])
        end

        unless ::File.exist?("#{onms_home}/etc/configured")
          shell_out!("#{onms_home}/bin/install -dis", returns: [0])
        end

        # stop current service until we have important things reconverged
        shell_out("#{onms_home}/bin/opennms stop", returns: [0])
        Chef::Log.info 'All *.rpmnew and *.rpmsave files moved into place.'

      end
    end

    def self.upgrade?(node)
      if ::File.exist?("#{node['opennms']['conf']['home']}/bin/opennms")
        version = shell_out!("/bin/rpm -q --queryformat '%{VERSION}-%{RELEASE}\n' opennms-core", returns: [0])
        Chef::Log.debug "Currently installed version of opennms-core: #{version.stdout.chomp}. Going to install #{node['opennms']['version']}."
        return version.stdout.chomp != node['opennms']['version']
      end
      false
    end

    def self.stop_opennms(node)
      if ::File.exist?("#{node['opennms']['conf']['home']}/bin/opennms")
        shell_out("#{node['opennms']['conf']['home']}/bin/opennms stop")
      end
    end

    def self.check_for_upgrade(dir)
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

    def self.clean_dir(dir, type)
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
  end
end

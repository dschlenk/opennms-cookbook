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
            FileUtils.chown(@node['opennms']['username'], @node['opennms']['groupname'], "#{dir}/#{orig_file}.bak")
            FileUtils.mv("#{dir}/#{file}", "#{dir}/#{orig_file}")
            FileUtils.chown(@node['opennms']['username'], @node['opennms']['groupname'], "#{dir}/#{orig_file}")
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

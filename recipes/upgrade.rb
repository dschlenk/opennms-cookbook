ruby_block 'Perform OpenNMS Upgrade If Necessary' do
  block do
    require 'fileutils'
    Chef::Resource::RubyBlock.send(:include, Chef::Mixin::ShellOut)
    def checkForUpgrade(dir)
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
      Dir.foreach(dir) do |file|
        if match = file.match(/^(.*)\.#{type}$/)
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

    upgraded = false
    onms_home = node['opennms']['conf']['home']
    onms_home ||= '/opt/opennms'

    node['opennms']['upgrade_dirs'].each do |d|
      conf_dir = "#{onms_home}/#{d}"
      if ::File.exist?(conf_dir) # || ::File.exist?(jetty_dir) || ::File.exist?(etc_dc_dir)
        upgraded = checkForUpgrade(conf_dir)
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
        cmd = shell_out!("#{onms_home}/bin/runjava -s", returns: [0])
      end

      unless ::File.exist?("#{onms_home}/etc/configured")
        cmd = shell_out!("#{onms_home}/bin/install -dis", returns: [0])
      end

      # stop current service until we have important things reconverged
      cmd = shell_out("#{onms_home}/bin/opennms stop", returns: [0])
      Chef::Log.info 'All *.rpmnew and *.rpmsave files moved into place.'
    end
  end
end

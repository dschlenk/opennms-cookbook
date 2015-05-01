def checkForUpgrade(dir)
  found = false
  if ::File.exist?(dir)
    Dir.foreach(dir) do |file|
      found = file =~ /^.*\.rpmnew$/
      break if found
      found = file =~ /^.*\.rpmsave$/
      break if found
    end
  end
  found
end

def clean_dir(dir, type)
  Dir.foreach(dir) do |file|
    if match = file.match(/^(.*)\.#{type}$/)
      if type == 'rpmsave'
        bash "remove #{type}" do
          code "rm #{dir}/#{file}"
        end
      elsif type == 'rpmnew'
        orig_file = match.captures[0]
        bash "backup orig files" do
          code "cp #{dir}/#{orig_file} #{dir}/#{orig_file}.bak"
        end
        bash "move #{type} file into place" do
          code "mv #{dir}/#{file} #{dir}/#{orig_file}"
        end
      end
    end
  end
end

upgraded = false
etc_dir = "#{node['opennms']['conf']['home']}/etc"
etc_dc_dir = "#{etc_dir}/datacollection"
jetty_dir = "#{node['opennms']['conf']['home']}/jetty-webapps/opennms"
onms_home = node[:opennms][:conf][:home]
onms_home ||= '/opt/opennms'
# breaks during first run compile phase without this check
if ::File.exist?(etc_dir) || ::File.exist?(jetty_dir) || ::File.exist?(etc_dc_dir)
  if ::File.exist?(etc_dir)
    upgraded = checkForUpgrade(etc_dir)
  end
  unless upgraded
    if ::File.exist?(etc_dc_dir)
      upgraded = checkForUpgrade(etc_dc_dir)
    end
  end
  unless upgraded
    if ::File.exist?(jetty_dir)
      upgraded = checkForUpgrade(jetty_dir)
    end
  end

  if upgraded
    log "Stop OpenNMS to perform upgrade." do
      notifies :stop, 'service[opennms]', :immediately
    end
    if ::File.exist?(etc_dir)
      clean_dir(etc_dir, 'rpmnew')
      clean_dir(etc_dir, 'rpmsave')
    end
    if ::File.exist?(etc_dc_dir)
      clean_dir(etc_dc_dir, 'rpmnew')
      clean_dir(etc_dc_dir, 'rpmsave')
    end
    if ::File.exist?(jetty_dir)
      clean_dir(jetty_dir, 'rpmnew')
      clean_dir(jetty_dir, 'rpmsave')
    end

    execute "runjava" do
      cwd onms_home
      creates "#{onms_home}/etc/java.conf"
      command "#{onms_home}/bin/runjava -s"
    end

    execute "upgrade" do
      cwd onms_home
      creates "#{onms_home}/etc/configured"
      command "#{onms_home}/bin/install -dis"
    end

    log "All *.rpmnew and #.rpmsave files moved into place." do
      notifies :start, 'service[opennms]', :immediately
    end
  end
end

upgraded = false
etc_dir = "#{node['opennms']['conf']['home']}/etc"
jetty_dir = "#{node['opennms']['conf']['home']}/jetty-webapps/opennms"
# breaks during first run compile phase without this check
if ::File.exist?(etc_dir)  && ::File.exist?(jetty_dir)
  Dir.foreach(etc_dir) do |file|
    upgraded = file =~ /^.*\.rpmnew$/
    break if upgraded
    upgraded = file =~ /^.*\.rpmsave$/
    break if upgraded
  end

  def clean_dir(dir, type)
    Dir.foreach(dir) do |file|
      if match = file.match(/^(.*)\.#{type}$/)
        if type == 'rpmsave'
          bash "remove rpmsaves" do
            code "rm #{dir}/#{file}"
          end
        elsif type = 'rpmnew'
          orig_file = match.captures[0]
          bash "backup orig files" do
            code "cp #{dir}/#{orig_file} #{dir}/#{orig_file}.bak"
          end
          bash "move rpmnew file into place" do
            code "mv #{dir}/#{file} #{dir}/#{orig_file}"
          end
        end
      end
    end
  end

  if upgraded
    log "Stop OpenNMS to perform upgrade." do
      notifies :stop, 'service[opennms]', :immediately
    end
    clean_dir(etc_dir, 'rpmnew')
    clean_dir(etc_dir, 'rpmsave')
    clean_dir(jetty_dir, 'rpmnew')
    clean_dir(jetty_dir, 'rpmsave')

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

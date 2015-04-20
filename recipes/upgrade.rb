upgraded = false
etc_dir = "#{node['opennms']['conf']['home']}/etc"
jetty_dir = "#{node['opennms']['conf']['home']}/jetty-webapps/opennms"
Dir.foreach(etc_dir) do |file|
  upgraded = file =~ /^.*\.rpmnew$/
  break if upgraded
end

def clean_dir(dir, type)
  Dir.foreach(dir) do |file|
    if match = file.match(/^(.*)\.#{type}$/)
      orig_file = match.captures
      bash "backup orig files" do
        code "cp #{dir}/#{orig_file} #{dir}/#{orig_file}.bak"
      end
      bash "move #{type} files into place" do
        code "mv #{dir}/#{file} #{dir}/#{orig_file}"
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
  log "All *.rpmnew and #.rpmsave files moved into place."
end

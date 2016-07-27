include Syslog
def whyrun_supported?
  true
end

use_inline_resources

action :create do
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - updating file as necessary."
    updated = false
    unless new_resource.filename.nil?
      f = cookbook_file new_resource.filename do
        path "#{node['opennms']['conf']['home']}/etc/syslog/#{new_resource.filename}"
        owner 'root'
        group 'root'
        mode 00644
      end
      updated = f.updated_by_last_action?
    end
    new_resource.updated_by_last_action(updated)
  else
    converge_by("Create #{@new_resource}") do
      create_syslog_file
      new_resource.updated_by_last_action(true)
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsSyslogFile.new(@new_resource.name)
  @current_resource.name(@new_resource.name)

  if syslog_file_exists?(@current_resource.name, node) && syslog_file_included?(@current_resource.name, node)
    @current_resource.exists = true
  end
end

private

def create_syslog_file
  Chef::Log.debug "Placing new syslog file: '#{node['opennms']['conf']['home']}/etc/syslog/#{new_resource.name}'"
  cookbook_file new_resource.name do
    path "#{node['opennms']['conf']['home']}/etc/syslog/#{new_resource.name}"
    owner 'root'
    group 'root'
    mode 00644
  end
  add_file_to_syslog(new_resource.name, new_resource.position, node)
end

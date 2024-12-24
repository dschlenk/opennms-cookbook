
unified_mode true

property :secret_alias, String, required: true
property :username, String, sensitive: true, required: true
property :password, String, sensitive: true, required: true
property :extra_properties, Hash, sensitive: true, default: {}

action :create do
  pw = opennms_scv_password
  execute "create OpenNMS secret #{new_resource.name}" do
    cwd node['opennms']['conf']['home']
    user 'opennms'
    sensitive true
    if pw.nil?
      command "bin/scvcli set '#{new_resource.secret_alias}' '#{new_resource.username}' '#{new_resource.password}'"
    else
      command "bin/scvcli --password '#{pw}' set '#{new_resource.secret_alias}' '#{new_resource.username}' '#{new_resource.password}'"
    end
  end
end

action :create_if_missing do
  pw = opennms_scv_password
  execute "create OpenNMS secret #{new_resource.name}" do
    cwd node['opennms']['conf']['home']
    user 'opennms'
    sensitive true
    command "bin/scvcli set '#{new_resource.secret_alias}' '#{new_resource.username}' '#{new_resource.password}'"
    not_if "bin/scvcli list | grep '#{new_resource.secret_alias}'"
  end
end


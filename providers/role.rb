def whyrun_supported?
  true
end

use_inline_resources # ~FC113

action :create do
  Chef::Application.fatal!("Missing group  #{@current_resource.membership_group}.") unless @current_resource.group_exists
  Chef::Application.fatal!("Missing user  #{@current_resource.supervisor}.") unless @current_resource.supervisor_exists
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  else
    converge_by("Create #{@new_resource}") do
      create_role
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource.resource_for_node(:opennms_role, node).new(@new_resource.name)
  @current_resource.membership_group(@new_resource.membership_group)
  @current_resource.supervisor(@new_resource.supervisor)

  @current_resource.exists = true if rbac.role_exists?(@current_resource.name)
  if rbac.group_exists?(@current_resource.membership_group)
    @current_resource.group_exists = true
  end
  if rbac.user_exists?(@current_resource.supervisor)
    @current_resource.supervisor_exists = true
  end
end

private

def create_role
  add_role(new_resource)
end

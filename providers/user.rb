# frozen_string_literal: true
include Opennms::Rbac
def whyrun_supported?
  true
end

use_inline_resources # ~FC113

action :create do
  if @current_resource.exists && @current_resource.changed
    Chef::Log.info "#{@new_resource} already exists but has changed - updating."
    converge_by("Update #{@new_resource}") do
      create_user
    end
  elsif @current_resource.exists && !@current_resource.changed
    Chef::Log.info "#{@new_resource} already exists and not changed - nothing to do."
  else
    Chef::Log.info "#{@new_resource} does not exist - creating."
    converge_by("Create #{@new_resource}") do
      create_user
    end
  end
end

action :create_if_missing do
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  else
    converge_by("Create #{@new_resource}") do
      create_user
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource.resource_for_node(:opennms_user, node).new(@new_resource.name)
  @current_resource.full_name(@new_resource.full_name)
  @current_resource.user_comments(@new_resource.user_comments)
  @current_resource.password(@new_resource.password)
  @current_resource.password_salt(@new_resource.password_salt)
  @current_resource.roles(@new_resource.roles)
  @current_resource.duty_schedules(@new_resource.duty_schedules)

  if user_exists?(@current_resource.name, node)
    @current_resource.exists = true
    @current_resource.changed = true if user_changed?(@current_resource, node)
  end
end

private

def create_user
  add_user(new_resource, node)
end

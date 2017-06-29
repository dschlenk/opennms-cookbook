# frozen_string_literal: true
include Opennms::Rbac
def whyrun_supported?
  true
end

use_inline_resources

action :create do
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  else
    converge_by("Create #{@new_resource}") do
      create_user
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsUser.new(@new_resource.name)
  @current_resource.name(@new_resource.name)

  @current_resource.exists = true if user_exists?(@current_resource.name, node)
end

private

def create_user
  add_user(new_resource, node)
end

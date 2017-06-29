# frozen_string_literal: true
include Provision
def whyrun_supported?
  true
end

use_inline_resources

action :create do
  Chef::Application.fatal!("Missing foreign source #{@current_resource.foreign_source_name}.") unless @current_resource.foreign_source_exists
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  else
    converge_by("Create #{@new_resource}") do
      create_policy
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsPolicy.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.foreign_source_name(@new_resource.foreign_source_name)

  if foreign_source_exists?(@current_resource.foreign_source_name, node)
    @current_resource.foreign_source_exists = true
  end
  if policy_exists?(@current_resource.name, @current_resource.foreign_source_name, node)
    @current_resource.exists = true
  end
end

private

def create_policy
  add_policy(new_resource.name, new_resource.class_name,
    new_resource.params, new_resource.foreign_source_name, node)
end

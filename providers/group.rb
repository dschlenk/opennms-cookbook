include Rbac
include Map
def whyrun_supported?
    true
end

use_inline_resources

action :create do
  Chef::Application.fatal!("Missing a user in #{@current_resource.users}.") if !@current_resource.users_exist
  Chef::Application.fatal!("Missing map #{@current_resource.default_svg_map}.") if !@current_resource.map_exists
  if @current_resource.exists
    Chef::Log.info "#{ @new_resource } already exists - nothing to do."
  else
    converge_by("Create #{ @new_resource }") do
      create_group
      new_resource.updated_by_last_action(true)
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsGroup.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.default_svg_map(@new_resource.default_svg_map) unless @new_resource.default_svg_map.nil?
  @current_resource.users(@new_resource.users) unless @new_resource.users.nil?

  if users_exist?(@current_resource.users)
     @current_resource.users_exist = true
  end
  if map_exists?(@current_resource.default_svg_map, node) || @current_resource.default_svg_map.nil?
     @current_resource.map_exists = true
  end
  if group_exists?(@current_resource.name, node)
     @current_resource.exists = true
  end
end

private

def users_exist?(users)
  if !users.nil?
    users.each do |user|
      return false if !user_exists?(user, node)
    end
  end
  return true
end

def create_group
  Chef::Log.info "Adding group #{new_resource.name}."
  add_group(new_resource, node)
end

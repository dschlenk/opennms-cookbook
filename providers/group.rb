# frozen_string_literal: true
include Opennms::Rbac
include Map
def whyrun_supported?
  true
end

use_inline_resources

action :create do
  Chef::Application.fatal!("Missing a user in #{@current_resource.users}.") unless @current_resource.users_exist
  Chef::Application.fatal!("Missing map #{@current_resource.default_svg_map}.") unless @current_resource.map_exists
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  else
    converge_by("Create #{@new_resource}") do
      create_group
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsGroup.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.default_svg_map(@new_resource.default_svg_map) unless @new_resource.default_svg_map.nil?
  @current_resource.users(@new_resource.users) unless @new_resource.users.nil?

  @current_resource.users_exist = true if users_exist?(@current_resource.users)
  if map_exists?(@current_resource.default_svg_map, node) || @current_resource.default_svg_map.nil?
    @current_resource.map_exists = true
  end
  @current_resource.exists = true if group_exists?(@current_resource.name, node)
end

private

def users_exist?(users)
  unless users.nil?
    users.each do |user|
      return false unless user_exists?(user, node)
    end
  end
  true
end

def create_group
  Chef::Log.info "Adding group #{new_resource.name}."
  add_group(new_resource, node)
end

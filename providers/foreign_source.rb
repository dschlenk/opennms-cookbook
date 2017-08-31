# frozen_string_literal: true
include Provision
def whyrun_supported?
  true
end

use_inline_resources

action :create do
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  else
    converge_by("Create #{@new_resource}") do
      create_foreign_source
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsForeignSource.new(@new_resource.name)
  @current_resource.name(@new_resource.name)

  if foreign_source_exists?(@current_resource.name, node)
    @current_resource.exists = true
  end
end

private

def create_foreign_source
  add_foreign_source(new_resource.name, new_resource.scan_interval, node)
end

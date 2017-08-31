# frozen_string_literal: true
include Opennms::Rbac
def whyrun_supported?
  true
end

use_inline_resources

action :create do
  Chef::Application.fatal!("Missing role  #{@current_resource.role_name}.") unless @current_resource.role_exists
  Chef::Application.fatal!("User #{@current_resource.username} not in role.") unless @current_resource.user_in_group
  Chef::Application.fatal!("Times array not valid #{@current_resource.times}. See resource definition for required format.") unless @current_resource.times_valid
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  else
    converge_by("Create #{@new_resource}") do
      create_role_schedule
    end
  end
end

# rubocop:disable Metrics/BlockNesting
def load_current_resource
  @current_resource = Chef::Resource::OpennmsRoleSchedule.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.role_name(@new_resource.role_name)
  @current_resource.type(@new_resource.type)
  @current_resource.username(@new_resource.username)
  @current_resource.times(@new_resource.times)

  # nest things that depend on each other and could cause convergence to fail
  if role_exists?(@current_resource.role_name, node)
    @current_resource.role_exists = true
    if user_in_group?(group_for_role(@current_resource.role_name, node), @current_resource.username, node)
      @current_resource.user_in_group = true
      if times_valid?(@current_resource.times)
        @current_resource.times_valid = true
        if schedule_exists?(@current_resource.role_name, @current_resource.username, @current_resource.type, node)
          @current_resource.exists = true
        end
      end
    end
  end
end

private

def times_valid?(times)
  validity = true
  if !times.nil? && !times.empty?
    times.each do |time|
      if time.key?('begins') && time.key?('ends')
        # check format of begins and ends
        unless time['begins'] =~ /^[0-9]{1,2}-(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)-[0-9]{4} [0-9]{1,2}:[0-9]{2}:[0-9]{2}$/ || time['begins'] =~ /^[0-9]{1,2}:[0-9]{2}:[0-9]{2}$/
          validity = false
        end
        unless time['ends'] =~ /^[0-9]{1,2}-(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)-[0-9]{4} [0-9]{1,2}:[0-9]{2}:[0-9]{2}$/ || time['ends'] =~ /^[0-9]{1,2}:[0-9]{2}:[0-9]{2}$/
          validity = false
        end
        # if has day, check that too
        if time.key?('day')
          validity = false unless time['day'] =~ /^(monday|tuesday|wednesday|thursday|friday|saturday|sunday|[1-3][0-9]|[1-9])$/
        end
      else
        # because missing beings/ends keys
        validity = false
      end
    end
  else
    # because times is nil or empty - need at least one
    validity = false
  end
  validity
end
# rubocop:enable Metrics/BlockNesting

def create_role_schedule
  add_schedule_to_role(new_resource, node)
end

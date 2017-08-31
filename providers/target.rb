# frozen_string_literal: true
def whyrun_supported?
  true
end

use_inline_resources

action :create do
  Chef::Application.fatal!("Missing destination path #{@current_resource.destination_path_name}.") unless @current_resource.destination_path_exists
  Chef::Application.fatal!('Need at least 1 command per target. ') unless @current_resource.minimum_commands
  Chef::Application.fatal!("At least one command in #{@current_resource.commands} does not exist in notificationCommands.xml.") unless @current_resource.commands_exist
  Chef::Application.fatal!('Missing required escalate_delay attribute for escalate type target!') unless @current_resource.delay_defined
  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  else
    converge_by("Create #{@new_resource}") do
      create_target
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::OpennmsTarget.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.target_name(@new_resource.target_name)
  @current_resource.type(@new_resource.type)
  @current_resource.destination_path_name(@new_resource.destination_path_name)
  @current_resource.commands(@new_resource.commands)
  @current_resource.escalate_delay(@new_resource.escalate_delay) unless @new_resource.escalate_delay.nil?

  if destination_path_exists?(@current_resource.destination_path_name)
    @current_resource.destination_path_exists = true
    if target_exists?(@current_resource.destination_path_name, @current_resource.target_name, @current_resource.type)
      @current_resource.exists = true
    end
    if minimum_commands?(@current_resource.commands)
      @current_resource.minimum_commands = true
      if commands_exist?(@current_resource.commands)
        @current_resource.commands_exist = true
      end
    end
    if @current_resource.type == 'escalate' && !@current_resource.escalate_delay.nil?
      @current_resource.delay_defined = true
    elsif @current_resource.type == 'target'
      @current_resource.delay_defined = true
    end
  end
end

private

def destination_path_exists?(destination_path_name)
  Chef::Log.debug "Checking to see if this destination path exists: '#{destination_path_name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/destinationPaths.xml", 'r')
  doc = REXML::Document.new file
  file.close
  !doc.elements["/destinationPaths/path[@name='#{destination_path_name}']"].nil?
end

def target_exists?(destination_path_name, name, type)
  Chef::Log.debug "Checking to see if this target exists: '#{name}' of type '#{type}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/destinationPaths.xml", 'r')
  doc = REXML::Document.new file
  file.close
  if type == 'target'
    !doc.elements["/destinationPaths/path[@name='#{destination_path_name}']/target/name[text() = '#{name}']"].nil?
  else
    !doc.elements["/destinationPaths/path[@name='#{destination_path_name}']/escalate/target/name[text() = '#{name}']"].nil?
  end
end

def minimum_commands?(commands)
  !commands.nil? && !commands.empty?
end

def commands_exist?(commands)
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/notificationCommands.xml", 'r')
  doc = REXML::Document.new file
  file.close
  commands_exist = true
  commands.each do |command|
    Chef::Log.debug "Checking to see if this command exists: '#{command}'"
    if doc.elements["/notification-commands/command/name[text() = '#{command}']"].nil?
      commands_exist = false
      break
    end
  end
  commands_exist
end

def create_target
  Chef::Log.debug "Creating target : '#{new_resource.name}'"
  file = ::File.new("#{node['opennms']['conf']['home']}/etc/destinationPaths.xml", 'r')
  contents = file.read
  doc = REXML::Document.new(contents, respect_whitespace: :all)
  doc.context[:attribute_quote] = :quote
  file.close

  path_el = doc.elements["/destinationPaths/path[@name='#{new_resource.destination_path_name}']"]

  # build new target element - same for plain target or escalate
  target_el = REXML::Element.new 'target'
  if !new_resource.interval.nil? && new_resource.interval != '0s'
    target_el.attributes['interval'] = new_resource.interval
  end
  name_el = target_el.add_element 'name'
  name_el.add_text(new_resource.target_name)
  unless new_resource.auto_notify.nil?
    an_el = target_el.add_element 'autoNotify'
    an_el.add_text(new_resource.auto_notify)
  end
  new_resource.commands.each do |command|
    command_el = target_el.add_element 'command'
    command_el.add_text(command)
  end

  # add target element to appropriate place in path
  if new_resource.type == 'target'
    path_el.add_element target_el
    Chef::Log.debug 'Added target element to path.'
  elsif new_resource.type == 'escalate'
    # first see if an existing escalate element already exists
    escalate_el = path_el.elements["escalate[@delay='#{new_resource.escalate_delay}']"]
    # and create a new one if it doesn't
    if escalate_el.nil?
      escalate_el = path_el.add_element 'escalate', 'delay' => new_resource.escalate_delay
      Chef::Log.debug 'Added target element to new escalate element that was added to path_el.'
    end
    # add target! we're done!
    escalate_el.add_element target_el
    Chef::Log.debug 'Added target element to existing escalate element.'
  end

  Opennms::Helpers.write_xml_file(doc, "#{node['opennms']['conf']['home']}/etc/destinationPaths.xml")
end

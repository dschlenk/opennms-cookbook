# frozen_string_literal: true

# ==============================================================================
# CHEFSPEC CUSTOM MATCHERS
# ==============================================================================
# This file provides the bridge between our custom resource definitions and
# ChefSpec's simulation engine. It allows us to write clean RSpec assertions
# like `expect(chef_run).to create_opennms_event('name')`.
# ==============================================================================

if defined?(ChefSpec)
  # Matcher for the default ':create' action
  def create_opennms_event(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:opennms_event, :create, resource_name)
  end

  # Matcher for the ':create_if_missing' action
  def create_if_missing_opennms_event(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:opennms_event, :create_if_missing, resource_name)
  end

  # Matcher for the ':update' action
  def update_opennms_event(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:opennms_event, :update, resource_name)
  end

  # Matcher for the ':delete' action
  def delete_opennms_event(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:opennms_event, :delete, resource_name)
  end
end

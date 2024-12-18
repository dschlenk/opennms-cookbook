include Opennms::Cookbook::Provision::ModelImportHttpRequest
include Opennms::XmlHelper
include Opennms::Rbac


property :foreign_source_name, String, default: 'imported:'
property :sync_import, [TrueClass, FalseClass], default: false
property :sync_wait_periods, Integer, default: 30
property :sync_wait_secs, Integer, default: 10
property :class_name, String
property :foreign_source_name, String, identity: true

load_current_value do |new_resource|
  model_import = REXML::Document.new(model_import(new_resource.foreign_source_name).message) unless model_import(new_resource.foreign_source_name).nil?
  model_import = REXML::Document.new(Opennms::Cookbook::Provision::ModelImport.new(new_resource.foreign_source_name, "#{baseurl}/requisitions/#{new_resource.foreign_source_name}").message) if model_import.nil?
  current_value_does_not_exist! if model_import.nil?
  Chef::Log.debug "add_import response is: #{model_import}"
end

action_class do
  include Opennms::Cookbook::Provision::ForeignSourceHttpRequest
  include Opennms::XmlHelper
  include Opennms::Rbac
end

action :create do
  converge_if_changed do
    model_import_init(new_resource.foreign_source_name, node)
    model_import = REXML::Document.new(model_import(new_resource.foreign_source_name).message).root
    model_import(new_resource.foreign_source_name).message model_import.to_s
    if !new_resource.sync_import.nil? && new_resource.sync_import
      model_import_sync(new_resource.foreign_source_name, true)
    end
  end
end

action :sync do
  converge_if_changed do
    model_import_init(new_resource.foreign_source_name, node)
    model_import_sync(new_resource.foreign_source_name, true)
  end
end